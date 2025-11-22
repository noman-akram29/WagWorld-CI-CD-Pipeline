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

        // stage('Maven Compile') { steps { sh 'mvn clean compile' } }
        // stage('Maven Test')    { steps { sh 'mvn test' } }
        // stage('Build WAR')      { steps { sh 'mvn clean install -DskipTests=true' } }

        // stage('SonarQube Analysis') {
        //     steps {
        //         withSonarQubeEnv('SonarQube-Server') {
        //             sh '''
        //                 $SCANNER_HOME/bin/sonar-scanner \
        //                 -Dsonar.projectName=WagWorld \
        //                 -Dsonar.projectKey=WagWorld \
        //                 -Dsonar.java.binaries=.
        //             '''
        //         }
        //     }
        // }

        // stage('OWASP Dependency Check') {
        //     steps {
        //         dependencyCheck additionalArguments: '--scan ./ --format XML', odcInstallation: 'Dependency-Check'
        //         dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
        //     }
        // }

        // stage('Code Quality Gate') {
        //     steps {
        //         script {
        //             waitForQualityGate abortPipeline: false, credentialsId: 'SonarQube-Token-for-Jenkins'
        //         }
        //     }
        // }

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
                    echo "Listing workspace:"
                    ls -al $WORKSPACE
                    echo "Listing inside WORKSPACE to verify playbook:"
                    ls -al

                    ansible-playbook -i localhost, docker-playbook.yaml \
                    -c local \
                    --extra-vars "docker_hub_user=${DOCKER_USER} docker_pat=${DOCKER_PAT} workspace_dir=$WORKSPACE"
                    '''
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                dir("${WORKSPACE}") {  // Ensure we are in the correct workspace where the playbook exists
                    script {
                        // Use SSH agent with the private key that matches the public key in k8s-master-server
                        sshagent(credentials: ['SSH-Key-for-K8s']) {  // <-- Create this credential in Jenkins (private key)
                            
                            // Optional: Copy kubeconfig secret file from Jenkins credentials to agent if needed
                            // (Only required if kubeconfig is not already present on the target node)
                            withCredentials([file(credentialsId: 'K8s-Secret', variable: 'KUBECONFIG_SECRET')]) {
                                sh '''
                                    echo "Copying kubeconfig to remote k8s-master-server..."
                                    scp -o StrictHostKeyChecking=no $KUBECONFIG_SECRET ubuntu@172.31.67.4:/home/ubuntu/.kube/config
                                    ssh -o StrictHostKeyChecking=no ubuntu@172.31.67.4 "chmod 600 /home/ubuntu/.kube/config"
                                '''
                            }

                            // Run the Ansible playbook that applies the Kubernetes manifest
                            ansiblePlaybook(
                                playbook: 'k8s-deployment-playbook.yml',
                                inventory: '/etc/ansible/hosts',           // Your inventory containing k8s-master-server
                                credentialsId: 'SSH-Key-for-K8s',  // Same SSH key
                                disableHostKeyChecking: true,
                                installation: 'ansible',
                                extras: '-e "workspace_dir=${WORKSPACE}"' // Optional: pass workspace if needed inside playbook
                            )
                        }
                    }
                }
            }
        }
    }
}
