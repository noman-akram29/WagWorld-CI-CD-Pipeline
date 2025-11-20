pipeline{
    agent any
    tools {
        jdk 'JDK-17.0.8.1'
        maven 'Maven-3.9.11'
    }
    stages{
        stage ('Workspace CleanUp'){
            steps{
                cleanWs()
            }
        }
        stage ('CheckOut SCM') {
            steps {
                git 'https://github.com/noman-akram29/WagWorld-CI-CD-Pipeline.git'
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
   }
}