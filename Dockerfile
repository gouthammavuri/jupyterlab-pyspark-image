
# Use an official Python base image for reliability
FROM python:3.14-slim AS base

ARG JDK_VERSION=21.0.8
ARG SCALA_VERSION=2.13.1
ARG SPARK_VERSION=4.0.1
ADD https://aka.ms/download-jdk/microsoft-jdk-${JDK_VERSION}-linux-x64.tar.gz .
ADD https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz .
ADD https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz .
RUN tar -xvzf microsoft-jdk-${JDK_VERSION}-linux-x64.tar.gz \
    && mv jdk-${JDK_VERSION}+9 jdk-${JDK_VERSION} \
    && mv jdk-${JDK_VERSION} /usr/local/jdk-${JDK_VERSION} \
    && rm microsoft-jdk-${JDK_VERSION}-linux-x64.tar.gz \
    && tar -xvzf scala-${SCALA_VERSION}.tgz \
    && mv scala-${SCALA_VERSION} /usr/local/scala \
    && rm scala-${SCALA_VERSION}.tgz \
    && tar -xvzf spark-${SPARK_VERSION}-bin-hadoop3.tgz \
    && mv spark-${SPARK_VERSION}-bin-hadoop3 /usr/local/spark \
    && rm spark-${SPARK_VERSION}-bin-hadoop3.tgz

# Install system dependencies required for building Python packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    g++ \
    gcc \
    unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip and install Python packages
RUN pip install --upgrade pip && \
    pip install \
        JayDeBeApi \
        findspark \
        ipykernel \
        ipywidgets \
        jupyter \
        jupyterlab \
        matplotlib \
        neo4j \
        notebook \
        numpy \
        pandas \
        plotly \
        pyodbc \
        pyspark==4.0.1 \
        scikit-learn \
        scipy \
        seaborn \
        sqlalchemy

# Confirm installations
RUN pip --version && jupyter-lab --version


# Set up Java environment variables
ENV JAVA_HOME=/usr/local/jdk-${JDK_VERSION}
ENV PATH=$JAVA_HOME/bin:$PATH

# Set up Scala environment variables
ENV SCALA_HOME=/usr/local/scala
ENV PATH=$SCALA_HOME/bin:$PATH

# Set up Spark environment variables
ENV SPARK_HOME=/usr/local/spark
ENV CLASSPATH=/usr/local/spark/jars/*
ENV PATH=$SPARK_HOME/bin:$PATH

# Clear JupyterLab state
RUN jupyter lab clean

# Create a working directory and set permissions
WORKDIR /home/gmavuri/work
RUN chmod -R a+rwx /home/gmavuri/work

# Environment variables related to Jupyter Notebook
ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=python3

# Expose Jupyter Notebook port
EXPOSE 8888

# Add a health check to verify that the JupyterLab server is running
HEALTHCHECK CMD curl --fail http://localhost:8888 || exit 1

# Create Jupyter configuration file to set token and password, and verify its creation
RUN mkdir -p /root/.jupyter \
    && echo "c.NotebookApp.token = 'welcome123'" >> /root/.jupyter/jupyter_notebook_config.py \
    && ls -alh /root/.jupyter \
    && cat /root/.jupyter/jupyter_notebook_config.py


# Set default command to start Jupyter Notebook
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root"]