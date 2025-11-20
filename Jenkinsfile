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
                git branch: 'main', url: 'https://github.com/noman-akram29/WagWorld-CI-CD-Pipeline.git'
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
        stage ('Build war file'){
            steps{
                sh 'mvn clean install -DskipTests=true'
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
        stage("OWASP Dependency Check"){
            steps{
                dependencyCheck additionalArguments: '--scan ./ --format XML ', odcInstallation: 'Dependency-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
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