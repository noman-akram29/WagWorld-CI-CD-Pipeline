# WagWorld CI/CD Pipeline

This repository implements a **full CI/CD pipeline** for the WagWorld Store application using:

- **Jenkins** for orchestration  
- **Maven** for building a Java web application (WAR)  
- **SonarQube** for static code analysis  
- **OWASP Dependency-Check** for security scanning  
- **Docker** for containerization  
- **Ansible** for deployment automation  
- **Kubernetes** for production deployment  

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)  
2. [Pipeline Stages](#pipeline-stages)  
3. [Kubernetes Deployment](#kubernetes-deployment)  
4. [Ansible Playbook](#ansible-playbook)  
5. [Docker Setup](#docker-setup)  
6. [Prerequisites](#prerequisites)  
7. [How to Use / Run the Pipeline](#how-to-use--run-the-pipeline)  
8. [Project Structure](#project-structure)  
9. [Credentials & Secrets](#credentials--secrets)  
10. [Contributing](#contributing)  
11. [License](#license)  

---

## Architecture Overview

1. Developers push code to GitHub.  
2. Jenkins pipeline is triggered, doing compilation, testing, packaging, static analysis, and security scanning.  
3. Jenkins builds a Docker image containing the WAR file and pushes it to Docker Hub.  
4. Ansible playbook runs locally (on Jenkins or a control node) to build and push Docker image, then remove any existing container and start a new one.  
5. Using SSH, Jenkins (via Ansible) applies Kubernetes manifests to a cluster:  
   - A **Deployment** with 2 replicas  
   - A **LoadBalancer** Service exposing the application  

---

## Pipeline Stages

The Jenkins pipeline includes:

- **Workspace Cleanup**: Clean the Jenkins workspace before each run  
- **SCM Checkout**: Checkout code from GitHub (`main` branch)  
- **Maven Compile**: `mvn clean compile`  
- **Maven Test**: `mvn test`  
- **Build WAR**: `mvn clean install -DskipTests=true`  
- **SonarQube Analysis**: Analyze code with SonarQube  
- **OWASP Dependency Check**: Run dependency-check and publish report  
- **Code Quality Gate**: Wait for quality gate result (Sonar)  
- **Docker Build & Deploy**: Use Ansible to build/push Docker image  
- **Deploy to Kubernetes**: Use Ansible + `kubectl` (via playbook) to deploy  

---

## Kubernetes Deployment

Here is a summary of the Kubernetes manifest (based on your YAML):

- **Deployment** `wagworld-store`  
  - 2 replicas  
  - Rolling update strategy (maxSurge: 1, maxUnavailable: 0)  
  - Container: `nomanakram29/wagworld-store:latest`  
  - Resource requests: `256Mi` memory, `200m` CPU  
  - Resource limits: `512Mi` memory, `500m` CPU  
  - Health checks: `livenessProbe`, `readinessProbe`, `startupProbe` all hitting `/healthz` on port `8080`  

- **Service** `wagworld-store`  
  - Type: `LoadBalancer`  
  - Exposes port `80` → target port `8080`  

---

## Ansible Playbook

There are two main playbooks:

1. **`docker-playbook.yaml`**  
   - Hosts: `localhost` (Jenkins control)  
   - Logs into Docker Hub using provided credentials  
   - Builds Docker image from workspace  
   - Tags the image `docker_hub_user/wagworld-store:latest`  
   - Pushes the image  
   - Removes old container (if exists)  
   - Runs new container, mapping host port `8082` → container port `8080`  

2. **`k8s-deployment-playbook.yml`**  
   - Uses Kubernetes module (`kubernetes.core.k8s`)  
   - Reads `k8s-deployment.yaml` manifest  
   - Applies the manifest to the Kubernetes cluster  
   - Requires `kubeconfig` on target node (copied via SSH from Jenkins)  

---

## Docker Setup

- Base image: `tomcat:9.0.93-jre17-temurin-jammy`  
- Removes default Tomcat `webapps`  
- Copies `target/jpetstore.war` (built by Maven) into `ROOT.war`  
- Exposes port `8080`  

---

## Prerequisites

To run this pipeline, you need:

- **Jenkins** with the following:  
  - JDK 17  
  - Maven 3.x  
  - SonarQube Scanner  
  - Ansible installed / configured as a tool  
  - SSH credentials to Kubernetes master node  
  - Docker Hub credentials in Jenkins (username & token)  
  - Kubeconfig to connect to the Kubernetes cluster  

- **Docker Hub** account (to push the image)  

- **Kubernetes cluster** (at least one master/control node that Ansible can ssh into)  

---

## How to Use / Run the Pipeline

1. **Setup Credentials in Jenkins**:  
   - DockerHub (username & PAT)  
   - SSH key for Kubernetes master node  
   - Kubeconfig (if using as a secret file)  

2. **Configure Jenkins Global Tools**:  
   - JDK  
   - Maven  
   - SonarQube Scanner  

3. **Add a Jenkins Pipeline Job**:  
   - Use the `Jenkinsfile` from this repo  
   - Set up webhooks (optional) so pushing to GitHub can trigger builds  

4. **Run the Playbooks**:  
   - The Docker build & deploy is handled via Ansible playbook from Jenkins  
   - Kubernetes manifests are applied by Ansible + `k8s-deployment-playbook.yml`  

5. **Monitor**:  
   - Jenkins -> pipeline status  
   - SonarQube / Dependency-Check reports  
   - Kubernetes: `kubectl get pods`, `kubectl get svc` to check deployment  

---

## Project Structure

Here’s a rough structure of the repo:


---
├── Dockerfile
├── Jenkinsfile
├── LICENSE
├── LICENSE_HEADER
├── NOTICE
├── README.md
├── dependency-check-report.xml
├── docker-playbook.yaml
├── format.xml
├── k8s-deployment-playbook.yml
├── k8s-deployment.yaml
├── mvnw
├── mvnw.cmd
├── pom.xml
├── renovate.json
├── src
│   ├── main
│   ├── site
│   └── test
└── target
    ├── cargo
    ├── classes
    ├── formatter-maven-cache.properties
    ├── generated-sources
    ├── generated-test-sources
    ├── impsort-maven-cache.properties
    ├── jpetstore
    ├── jpetstore.war
    ├── maven-archiver
    ├── osgi
    ├── site
    └── test-classes

15 directories, 18 files
---

## Credentials & Secrets

- **Docker Hub credentials**: used in Jenkins (DOCKER_USER, DOCKER_PAT)  
- **SSH key**: Jenkins uses SSH agent to deploy to Kubernetes master  
- **Kubeconfig**: either stored in Jenkins or copied via credentials `file` credential  

> ⚠️ Make sure to **never commit** your secrets (passwords, tokens, private keys, kubeconfig) directly to the repository.

---

## Contributing

If you want to contribute or improve this pipeline:

1. Fork the repo  
2. Make changes (e.g., better health checks, multi-environment support, Helm)  
3. Submit a pull request with a clear description of your changes  

---

## License

Specify your license here (e.g., **MIT**, **Apache-2.0**, or other).  
If you don’t have one yet, you might want to add a `LICENSE` file to clarify how others can use your project.

---

## Next Steps / Enhancements

Here are some ideas for improving this project further:

- Use **Helm** for Kubernetes manifests, for better templating and multi-environment deployments  
- Add **rolling updates** with image version tagging (instead of `latest`)  
- Integrate **GitOps** (e.g. Flux or Argo CD) for declarative deployments  
- Use **Trivy** (or other scanner) for container vulnerability scanning  
- Add more tests (integration, UI), and deploy to staging / prod environments  

---

Let me know if you like this, or if you want me to modify / expand any section (e.g. add badges, diagrams, etc.).
::contentReference[oaicite:0]{index=0}
