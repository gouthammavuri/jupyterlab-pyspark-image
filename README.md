# Ubuntu JupyterLab with Apache Spark and PySpark

## Overview

This Docker image is based on the official Ubuntu 24.04 image and comes pre-configured with Python 3.11, JupyterLab, Apache Spark, and PySpark. It is designed to provide a robust development environment for data science and big data processing.

## Features

- **Ubuntu 24.04**: The base operating system.
- **Python 3.11.9**: The latest version of Python for development.
- **JupyterLab**: An interactive development environment for notebooks, code, and data.
- **Apache Spark 3.4.3**: A powerful engine for big data processing.
- **PySpark**: Python API for Apache Spark.
- **Common Data Science Libraries**: Including Pandas, NumPy, Matplotlib, Seaborn, SciPy, Scikit-learn, Plotly, and IPyWidgets.
- **OpenJDK 17**: Required for running Apache Spark.

## Usage

### Running the Container

To run the container, use the following command:

```sh
docker run -p 8888:8888 -v /scripts:/home/gmavuri/work gouthammavuri/jupyter-pyspark-image
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
