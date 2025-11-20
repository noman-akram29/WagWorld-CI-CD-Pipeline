pipeline{
    agent any
    tools {
        jdk 'JDK-17.0.8.1'
        maven 'Maven-3.9.11'
    }
    environment {
        SCANNER_HOME=tool 'SonarQube-Scanner'
    }
    stages{
        stage ('Workspace CleanUp'){
            steps{
                cleanWs()
            }
        }
        stage ('CheckOut SCM') {
            steps {
                git branch: 'main', url: 'https://github.com/noman-akram29/Jave-Application-CICD-using-Jenkins-Ansible-and-Docker.git'
            }
        }
        stage ('Maven Compile') {
            steps {
                sh 'mvn clean compile'
            }
        }
        stage ('Maven Test') {
            steps {
                sh 'mvn test'
            }
        }
        stage("SonarQube Analysis "){
            steps{
                withSonarQubeEnv('SonarQube-Server') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner \
                    -Dsonar.projectName=WagWorld \
                    -Dsonar.java.binaries=. \
                    -Dsonar.projectKey=WagWorld '''
                }
            }
        }
        stage("Code Quality Gate"){
            steps {
                script {
                waitForQualityGate abortPipeline: false, credentialsId: 'SonarQube-Token-for-Jenkins'
                }
            }
        }
   }
}