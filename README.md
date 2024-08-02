## TrustWallet Polygon Client PoC

This is a simple blockchain client written in Go. It interacts with the Ethereum blockchain via the Polygon RPC endpoint. The application exposes APIs to get the current block number and fetch block details by block number. The service is deployed on AWS ECS Fargate and is accessible via both a direct IP and an Application Load Balancer (ALB).

### Public Access Points

- **Direct DNS Record of ALB:** [http://trustwallet-alb-1569294843.eu-west-2.elb.amazonaws.com/getBlockNumber](http://trustwallet-alb-1569294843.eu-west-2.elb.amazonaws.com/getBlockNumber)

### API Endpoints

#### 1. Get Block Number

Retrieve the latest block number from the Ethereum blockchain.

- **Endpoint:**
  ```
  GET /getBlockNumber
  ```

- **Example Request:**
  ```sh
  curl -X GET http://trustwallet-alb-1569294843.eu-west-2.elb.amazonaws.com/getBlockNumber
  ```

- **Example Response:**
  ```json
  {
    "jsonrpc": "2.0",
    "id": 2,
    "result": "0x10d4f" // Block number in hex
  }
  ```

#### 2. Get Block by Number

Retrieve the details of a specific block by its number.

- **Endpoint:**
  ```
  GET /getBlockByNumber?blockNumber={blockNumber}
  ```

- **Query Parameters:**
  - `blockNumber`: The block number in hexadecimal format (e.g., `0x10d4f`).

- **Example Request:**
  ```sh
  curl -X GET "http://trustwallet-alb-1569294843.eu-west-2.elb.amazonaws.com/getBlockByNumber?blockNumber=0x134e82a"
  ```

- **Example Response:**
  ```json
  {
    "jsonrpc": "2.0",
    "id": 2,
    "result": {
      "number": "0x134e82a",
      "hash": "0x...",
      "parentHash": "0x...",
      "nonce": "0x...",
      // more block details...
    }
  }
  ```

#### 3. Health Check

Health check endpoint to verify the application status.

- **Endpoint:**
  ```
  GET /health
  ```

- **Example Request:**
  ```sh
  curl -X GET http://trustwallet-alb-1569294843.eu-west-2.elb.amazonaws.com/health
  ```

- **Example Response:**
  ```sh
  OK
  ```

### Deployment Details

This application is deployed on AWS ECS Fargate. Below are the main components and their configurations:

#### ECS Cluster

- **Name:** `trustwallet-cluster`

#### ECS Task Definition

- **Family:** `trustwallet-task`
- **Network Mode:** `awsvpc`
- **Requires Compatibilities:** `FARGATE`
- **CPU:** `256`
- **Memory:** `512`
- **Execution Role ARN:** Defined in the Terraform configuration.
- **Task Role ARN:** Defined in the Terraform configuration.
- **Container Definitions:**
  - **Name:** `trustwallet`
  - **Image:** `ricard0/trustwallet:latest`
  - **Essential:** `true`
  - **Port Mappings:** `8080:8080`
  - **Log Configuration:**
    - **Log Driver:** `awslogs`
    - **Options:**
      - `awslogs-group`: `/ecs/trustwallet-service`
      - `awslogs-region`: `eu-west-2`
      - `awslogs-stream-prefix`: `ecs`

#### ECS Service

- **Name:** `trustwallet-service`
- **Cluster:** `trustwallet-cluster`
- **Task Definition:** `trustwallet-task`
- **Desired Count:** `1`
- **Launch Type:** `FARGATE`
- **Network Configuration:**
  - **Subnets:** Public subnets
  - **Security Groups:** Allows inbound traffic on port 8080
  - **Assign Public IP:** `true`
- **Load Balancer:**
  - **Target Group ARN:** Defined in the Terraform configuration.
  - **Container Name:** `trustwallet`
  - **Container Port:** `8080`
- **Health Check Grace Period:** `60 seconds`

### Logging and Monitoring

The application logs are sent to AWS CloudWatch Logs.

### Building and Pushing Docker Image

1. **Build the Docker Image:**

   ```sh
   docker build -t ricard0/trustwallet:latest .
   ```

2. **Push the Docker Image to Docker Hub:**

   ```sh
   docker push ricard0/trustwallet:latest
   ```

### Using Makefile for Local Development and CI/CD

To streamline the development and CI/CD process, you can use a Makefile.

#### Makefile

Create a Makefile in the root of your repository:

```makefile
.PHONY: test build docker-build docker-push

test:
	go test -v ./...

build:
	go build -o trustwallet

docker-build:
	docker build -t ricard0/trustwallet:latest .

docker-push:
	docker push ricard0/trustwallet:latest

ci: test build docker-build docker-push
```

#### Makefile Commands

- **Run the complete CI process (test, build, docker-build, docker-push):**
  ```sh
  make ci
  ```

### Integrating with GitHub Actions for CI/CD

To automate the process, you can use GitHub Actions.

#### GitHub Actions Workflow

Create a `.github/workflows/ci.yml` file:

```yaml
name: CI

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Go
      uses: actions/setup-go@v2
      with:
        go-version: 1.18

    - name: Install dependencies
      run: go mod download

    - name: Run tests
      run: make test

    - name: Log in to Docker Hub
      run: echo "${{ secrets.DOCKERHUB_PASSWORD }}" | docker login -u "${{ secrets.DOCKERHUB_USERNAME }}" --password-stdin

    - name: Build Docker image
      run: make docker-build

    - name: Push Docker image
      run: make docker-push
```

#### Configure Secrets

Go to your repository on GitHub, click on `Settings` > `Secrets` > `Actions`, and add the following secrets:
- `DOCKERHUB_USERNAME`: Your Docker Hub username.
- `DOCKERHUB_PASSWORD`: Your Docker Hub password.

### Integrate with Terraform Deployment

Ensure that your Terraform deployment uses the latest Docker image. After pushing the new Docker image, apply your Terraform configuration to deploy the latest tested version of your application.

#### Apply Terraform Configuration

1. **Initialize Terraform:**

   ```sh
   terraform init
   ```

2. **Apply Terraform Configuration:**

   ```sh
   terraform apply -var="region=eu-west-2" -var="vpc_id=vpc-xxxxxxxx" -var="subnets=[\"subnet-xxxxxxxx\",\"subnet-yyyyyyyy\"]"
   ```

Ricardo Alvarado, 2024
