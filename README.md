# Apache PySpark and Jupyter Lab Docker Image

This repository contains a Docker setup for running Jupyter Lab with PySpark. It is configured to connect to an external Spark cluster, with Spark master and workers running in separate containers.

## Prerequisites

- Docker installed on your machine.
- Internet connection to download necessary packages and dependencies.

## Setup

1. **Clone the repository**:

   ```bash
   git clone <repository-url>
   cd jupyterlab-pyspark-image
   ```

2. **Build the Docker image**:

   ```bash
   docker build -t jupyterlab-pyspark .
   ```

3. **Run the Docker container**:
   You can run the container in different modes by setting the `SPARK_MODE` environment variable in the `.env` file.

   - **Jupyter Lab mode**:

     ```bash
     docker run --env-file .env -p 8888:8888 jupyterlab-pyspark
     ```

## Environment Variables

The following environment variables can be configured for the Docker setup:

```plaintext
# Base image version
UBUNTU_VERSION=22.04

# Python configuration
PYTHON_VERSION=3.14.0

# JDK configuration
JDK_VERSION=21.0.8

# JupyterLab configuration
JUPYTER_PORT=8888
```

You can set these environment variables in a `.env` file or pass them directly when running the Docker container.

## Notes

- Ensure that the ports specified in the `.env` file are available on your host machine.
- Modify the `.env` file as needed to suit your environment and requirements.

## License

This project is licensed under the MIT License.

## Running the Docker Container with Mounted Volumes

If you need to access external data or configuration files from your JupyterLab environment, you can mount directories from your host machine into the container using the `-v` option.

### Example Command

```bash
docker run --env-file .env -p 8888:8888 -v /path/to/your/data:/home/gmavuri/work jupyterlab-pyspark
```

- Replace `/path/to/your/data` with the actual path on your host machine where the data or configuration files are located.
- The `-v` option maps the host directory to the container directory `/home/gmavuri/work`, where JupyterLab can access the files.

### Benefits of Using Volumes

- **Flexibility**: You can update the drivers without rebuilding the Docker image.
- **Efficiency**: Reduces the size of the Docker image and speeds up the build process.
- **Convenience**: Easily switch between different sets of drivers by changing the host directory.

Ensure that the drivers are accessible and correctly mapped to the container for Spark to function properly.

## Accessing JupyterLab

When you start the JupyterLab container, you can access it by navigating to `http://localhost:<JUPYTER_PORT>` in your web browser. Use the following token to log in:

- **Token**: `welcome123`

Ensure that the `JUPYTER_PORT` environment variable is set to the desired port in your `.env` file or Docker environment. The default port is 8888.
