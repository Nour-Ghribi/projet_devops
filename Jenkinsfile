pipeline {
    agent any

    stages {

        stage('Checkout code') {
            steps {
                // 🟢 ADAPTER la branche si ce n'est pas main (par ex: master)
                git branch: 'main', url: 'git@github.com:Nour-Ghribi/projet_devops.git'
            }
        }

        stage('Build & Unit Tests (JUnit)') {
            steps {
                sh 'mvn clean test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Analyse de la qualité du code...'
                sh '''
                    mvn sonar:sonar \
                      -Dsonar.projectKey=projet_devops \
                      -Dsonar.host.url=http://10.0.2.15:9000 \
                      -Dsonar.login=squ_f9a8079370255fa83be0a15efb4ddc8af96cac84
                '''
            }
        }

        stage('Package (JAR Spring Boot)') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Deploy to Nexus (Mise en place de la version)') {
            steps {
                sh '''
                    mvn deploy -DskipTests \
                      -DaltDeploymentRepository=deploymentRepo::default::http://admin:nexus@10.0.2.15:8081/repository/maven-releases/
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    // 🟢 l'image locale sera construite à partir du Dockerfile
                    sh 'docker build -t nourxgh/eventsproject:1.0.0 .'
                }
            }
        }

        stage('Push Docker Image to DockerHub') {
            steps {
                script {
                    // 🟢 ICI on utilise le credentials DockerHub (Username + PAT)
                    // Remplace 'dockerhub-conn' par l'ID EXACT de ton credentials
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-conn',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            docker push nourxgh/eventsproject:1.0.0
                        '''
                    }
                }
            }
        }

        stage('Deploy with docker-compose (Spring Boot + MySQL)') {
            steps {
                script {
                    sh 'docker compose down || true'
                    sh 'docker compose up -d'
                }
            }
        }
    }
}
