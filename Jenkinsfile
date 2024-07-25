pipeline {
    agent any

    tools {
        maven 'maven3'
    }

    environment {
        SCANNER_HOME = tool 'sonar'
    }

    stages {
        stage('Git Checkout') {
            steps {
                git branch: 'main', credentialsId: 'git-pro', url: 'https://github.com/kranthi619/dev-pro.git'
            }
        }

        stage('Compile') {
            steps {
                sh "mvn compile"
            }
        }

        stage('Test') {
            steps {
                sh "mvn test"
            }
        }

        stage('Trivy Scan') {
            steps {
                sh "trivy fs --format table -o trivy-fs-report.html ."
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar') {
                    sh '''$SCANNER_HOME/bin/sonar-scanner \
                        -Dsonar.projectKey=sonar \
                        -Dsonar.projectName=sonar \
                        -Dsonar.java.binaries=target'''
                }
            }
        }

        stage('Build') {
            steps {
                sh "mvn package"
            }
        }

        stage('Docker Image Creation') {
            steps {
                echo 'Building Docker image using Dockerfile'
                sh 'docker build -t kranthi619/dev-pro2 .'
            }
        }

        stage('Trivy Image Scan') {
            steps {
                sh "trivy image --format table -o trivy-image-report.html kranthi619/dev-pro2:latest"
            }
        }

        stage('Docker Login and Push') {
            steps {
                echo 'Logging in to Docker Hub'
                sh 'docker login -u kranthi619 -p Kranthi123#'
                sh 'docker push kranthi619/dev-pro2:latest'
            }
        }

        stage('deploy to k8s') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'my-cluster', contextName: '', credentialsId: 'eks-secret', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://34CD5432CEBE5B832A4641690A08F557.gr7.ap-south-1.eks.amazonaws.com') {
                    sh 'kubectl apply -f deployment-service.yml -n webapps'
                    sleep 30
                }
            }
        }

        stage('deployment verification') {
            steps {
                withKubeConfig(caCertificate: '', clusterName: 'my-cluster', contextName: '', credentialsId: 'eks-secret', namespace: 'webapps', restrictKubeConfigAccess: false, serverUrl: 'https://34CD5432CEBE5B832A4641690A08F557.gr7.ap-south-1.eks.amazonaws.com') {
                    sh 'kubectl get pods -n webapps'
                    sh 'kubectl get svc -n webapps'
                }
            }
        }
    }
}
