pipeline {
    agent any

    tools {
        jdk 'JDK-17.0.8.1'
        maven 'Maven-3.9.11'
    }

    environment {
        SCANNER_HOME = tool 'SonarQube-Scanner'
        DOCKER_USER  = credentials('DockerHub-Creds')
        DOCKER_PAT   = credentials('DockerHub-Creds')
    }

    stages {

        stage('Workspace Cleanup') {
            steps { cleanWs() }
        }

        stage('Checkout SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/noman-akram29/WagWorld-CI-CD-Pipeline.git'
            }
        }

        stage('Maven Compile') { steps { sh 'mvn clean compile' } }
        stage('Maven Test')    { steps { sh 'mvn test' } }
        stage('Build WAR')      { steps { sh 'mvn clean install -DskipTests=true' } }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube-Server') {
                    sh '''
                        $SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectName=WagWorld \
                        -Dsonar.projectKey=WagWorld \
                        -Dsonar.java.binaries=.
                    '''
                }
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --format XML', odcInstallation: 'Dependency-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }

        stage('Code Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'SonarQube-Token-for-Jenkins'
                }
            }
        }

        stage('Docker Build & Deploy') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'DockerHub-Creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PAT'
                )]) {

                    sh '''
                    echo "Current Directory:"
                    pwd
                    echo "Listing files:"
                    ls -al
                    echo "Listing workspace:"
                    ls -al $WORKSPACE

                    cd $WORKSPACE

                    echo "Listing inside WORKSPACE to verify playbook:"
                    ls -al

                    ansible-playbook -i localhost, docker-playbook.yaml \
                    -c local \
                    --extra-vars "docker_hub_user=${DOCKER_USER} docker_pat=${DOCKER_PAT}"
                    '''
                }
            }
        }
    }
}
