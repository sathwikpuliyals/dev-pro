pipeline {
    agent any

    tools {
        maven 'maven3'
        git 'Default' // Ensure this matches the name of the Git installation in Jenkins
    }

    environment {
        SCANNER_HOME = tool 'sonar'
        NEXUS_USER = credentials('nexus-username')
        NEXUS_PASSWORD = credentials('nexus-password')
    }

    stages {
        stage('Git Checkout') {
            steps {
                script {
                    try {
                        checkout([$class: 'GitSCM', branches: [[name: '*/main']], 
                                  doGenerateSubmoduleConfigurations: false, 
                                  extensions: [], 
                                  userRemoteConfigs: [[credentialsId: 'git-pro', url: 'https://github.com/kranthi619/dev-pro.git']]])
                    } catch (Exception e) {
                        echo "Error during Git checkout: ${e}"
                        currentBuild.result = 'FAILURE'
                        error "Git checkout failed"
                    }
                }
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

        stage('Deploy Artifacts to Nexus') {
            steps {
                withMaven(globalMavenSettingsConfig: 'settings', maven: 'maven3', traceability: true) {
                    sh '''
                        mvn deploy -DskipTests \
                        -DaltDeploymentRepository=snapshots::default::http://43.204.149.160:8081/repository/maven-snapshots/ \
                        -Dusername=$NEXUS_USER -Dpassword=$NEXUS_PASSWORD
                    '''
                }
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
    }
}
