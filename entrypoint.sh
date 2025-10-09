#!/bin/bash

# Validate critical environment variables
if [ -z "$SPARK_HOME" ] || [ -z "$SPARK_MODE" ]; then
    echo "SPARK_HOME and SPARK_MODE must be set"
    exit 1
fi

if [ "$SPARK_MODE" == "worker" ] && ([ -z "$SPARK_WORKER_CORES" ] || [ -z "$SPARK_WORKER_MEMORY" ] || [ -z "$SPARK_MASTER_URL" ]); then
    echo "SPARK_WORKER_CORES, SPARK_WORKER_MEMORY, and SPARK_MASTER_URL must be set for worker mode"
    exit 1
fi

if [ "$SPARK_MODE" == "master" ] && ([ -z "$SPARK_MASTER_PORT" ] || [ -z "$SPARK_MASTER_WEBUI_PORT" ]); then
    echo "SPARK_MASTER_PORT and SPARK_MASTER_WEBUI_PORT must be set for master mode"
    exit 1
fi

if [ "$SPARK_MODE" == "client" ] && [ -z "$SPARK_SUBMIT_ARGS" ]; then
    echo "SPARK_SUBMIT_ARGS must be set for client mode"
    exit 1
fi

# Function to start Spark Master
start_master() {
    echo "Starting Spark Master..."
    $SPARK_HOME/sbin/start-master.sh --port $SPARK_MASTER_PORT --webui-port $SPARK_MASTER_WEBUI_PORT
    if [ $? -ne 0 ]; then
        echo "Failed to start Spark Master"
        exit 1
    fi
    echo "Spark Master started successfully"
    tail -f /dev/null
}

# Function to start Spark Worker
start_worker() {
    echo "Starting Spark Worker..."
    $SPARK_HOME/sbin/start-worker.sh --cores $SPARK_WORKER_CORES --memory $SPARK_WORKER_MEMORY $SPARK_MASTER_URL
    if [ $? -ne 0 ]; then
        echo "Failed to start Spark Worker"
        exit 1
    fi
    echo "Spark Worker started successfully"
    tail -f /dev/null
}

# Function to start Spark History Server
start_history_server() {
    echo "Starting Spark History Server..."
    $SPARK_HOME/sbin/start-history-server.sh
    if [ $? -ne 0 ]; then
        echo "Failed to start Spark History Server"
        exit 1
    fi
    echo "Spark History Server started successfully"
    tail -f /dev/null
}


# Function to run Spark in client mode
run_client() {
    exec $SPARK_HOME/bin/spark-submit $SPARK_SUBMIT_ARGS
}

# Function to run JupyterLab
run_jupyterlab() {
    echo "Starting JupyterLab..."
    export PYSPARK_PYTHON=${PYSPARK_PYTHON:-python3}
    export PYSPARK_DRIVER_PYTHON=${PYSPARK_DRIVER_PYTHON:-python3}
    export SPARK_HOME=${SPARK_HOME:-/opt/spark}
    export PATH=$SPARK_HOME/bin:$PATH
    # Allow custom Jupyter args via env
    JUPYTER_ARGS="${JUPYTER_ARGS:-}"
    exec jupyter lab --ip=0.0.0.0 --port=${JUPYTER_PORT:-8888} --no-browser --allow-root $JUPYTER_ARGS
}

# Check SPARK_MODE environment variable
case "$SPARK_MODE" in
    master)
        exec start_master
        ;;
    worker)
        exec start_worker
        ;;
    client)
        exec run_client
        ;;
    history-server)
        exec start_history_server
        ;;
    jupyterlab)
        exec run_jupyterlab
        ;;
    ""|standalone)
        # Default to JupyterLab if SPARK_MODE is not set or set to 'standalone'
        exec run_jupyterlab
        ;;
    *)
        echo "Invalid SPARK_MODE: $SPARK_MODE. Must be 'master', 'worker', 'client', 'history-server', or 'jupyterlab'"
        exit 1
        ;;
esac
