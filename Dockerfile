# Use an official Ubuntu as a parent image
FROM ubuntu:24.04

# Set environment variables to non-interactive for automated installs
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    curl \
    git \
    vim \
    build-essential \
    ca-certificates \
    checkinstall \
    libncursesw5-dev \
    libssl-dev \
    libsqlite3-dev \
    tk-dev \
    libgdbm-dev \
    libc6-dev \
    libbz2-dev \
    libffi-dev \
    zlib1g-dev \
    nodejs \
    npm \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python
RUN wget https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz \
    && tar -xvzf Python-3.11.9.tgz \
    && cd Python-3.11.9 \
    && ./configure --enable-optimizations \
    && make altinstall \
    && /usr/local/bin/python3.11 -V \
    && ln -sf /usr/local/bin/python3.11 /usr/bin/python3.11 \
    && ln -sf /usr/local/bin/python3.11 /usr/bin/python3 \
    && cd .. \
    && rm -rf Python-3.11.9 \
    && rm Python-3.11.9.tgz

# Install pip using wget and add to PATH
RUN wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py \
    && /usr/local/bin/python3.11 get-pip.py \
    && rm get-pip.py \
    && echo "export PATH=\$PATH:/root/.local/bin" >> /root/.bashrc \
    && /usr/local/bin/python3.11 -m pip install --upgrade pip --verbose

# Install JupyterLab and IPython kernel
RUN /usr/local/bin/python3.11 -m pip install jupyterlab ipykernel

# Install common packages used with PySpark
RUN /usr/local/bin/python3.11 -m pip install pandas numpy matplotlib seaborn scipy scikit-learn plotly ipywidgets findspark pyspark==3.4.3

# Confirm installations
RUN bash -c "source /root/.bashrc && /usr/local/bin/python3.11 -m pip --version && jupyter-lab --version"

# Install OpenJDK 
RUN wget https://aka.ms/download-jdk/microsoft-jdk-17.0.12-linux-x64.tar.gz \
    && tar -xvzf microsoft-jdk-17.0.12-linux-x64.tar.gz \
    && mv jdk-17.0.12+7 jdk-17.0.12 \
    && mv jdk-17.0.12 /usr/local/jdk-17.0.12 \
    && rm microsoft-jdk-17.0.12-linux-x64.tar.gz

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/local/jdk-17.0.12
ENV PATH=$JAVA_HOME/bin:$PATH

# Install Apache Spark
RUN wget https://archive.apache.org/dist/spark/spark-3.4.3/spark-3.4.3-bin-hadoop3.tgz \
    && tar -xvzf spark-3.4.3-bin-hadoop3.tgz \
    && mv spark-3.4.3-bin-hadoop3 /usr/local/spark \
    && rm spark-3.4.3-bin-hadoop3.tgz

# Set SPARK_HOME environment variable
ENV SPARK_HOME=/usr/local/spark
ENV CLASSPATH=/usr/local/spark/jars/*
ENV PATH=$SPARK_HOME/bin:$PATH

# Create Jupyter configuration file
RUN mkdir -p /root/.jupyter && echo "c.ServerApp.token = ''" >> /root/.jupyter/jupyter_server_config.py

# Clear JupyterLab state
RUN jupyter lab clean

# Create a working directory and set permissions
WORKDIR /home/gmavuri/work
RUN chmod -R a+rwx /home/gmavuri/work

# Environment variables related to Jupyter Notebook
ENV PYSPARK_PYTHON=/usr/local/bin/python3.11
ENV PYSPARK_DRIVER_PYTHON=/usr/local/bin/python3.11

# Expose Jupyter Notebook port
EXPOSE 8888

# Add a health check to verify that the JupyterLab server is running
HEALTHCHECK CMD curl --fail http://localhost:8888 || exit 1

# Set default command to start Jupyter Notebook
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--NotebookApp.token=''"]
