
# Prompt for Docker Hub credentials
$username = Read-Host "Enter your Docker Hub username"
$password = Read-Host "Enter your Docker Hub password" -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential ($username, $password)

# Convert the password to plain text
$plainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($credential.Password))

# Log in to Docker Hub
Write-Host "Logging in to Docker Hub..."
try {
    $plainPassword | docker login --username $username --password-stdin
}
catch {
    Write-Host "Failed to log in to Docker Hub. Please check your credentials."
    exit 1
}

# Define variables
$imageName = "${username}/pyspark-jupyter-lab"  # The name of your Docker image
$dockerfilePath = "."  # The path to your Dockerfile
$tags = @("latest", "1.0.0", "stable", "python3.11.9-spark3.4.3-jdk17.0.9")  # List of tags

# Build the Docker image
Write-Host "Building Docker image..."
docker build -t "${imageName}:latest" $dockerfilePath

# Tag the Docker image with additional tags
foreach ($tag in $tags) {
    if ($tag -ne "latest") {
        Write-Host "Tagging Docker image with $tag..."
        docker tag "${imageName}:latest" "${imageName}:${tag}"
    }
}

# Push the Docker image with all tags to Docker Hub
foreach ($tag in $tags) {
    Write-Host "Pushing Docker image with tag $tag to Docker Hub..."
    docker push "${imageName}:${tag}"
}

# Logout from Docker Hub
Write-Host "Logging out from Docker Hub..."
docker logout

Write-Host "Docker image pushed to Docker Hub successfully with all tags."
