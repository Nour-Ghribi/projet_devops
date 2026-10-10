pipeline {
    agent any

    stages {

        

        stage('Build & Unit Tests (JUnit)') {
            steps {
                sh 'mvn clean test'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                echo 'Analyse de la qualité du code...'
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh '''
                        mvn sonar:sonar \
                          -Dsonar.projectKey=projet_devops \
                          -Dsonar.host.url=${SONAR_HOST_URL:-http://10.0.2.15:9000} \
                          -Dsonar.token=$SONAR_TOKEN
                    '''
                }
            }
        }

        stage('Package (JAR Spring Boot)') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Deploy to Nexus (Mise en place de la version)') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'nexus-deployer',
                                                  usernameVariable: 'NEXUS_USER',
                                                  passwordVariable: 'NEXUS_PASS')]) {
                    sh '''
                        mvn deploy -DskipTests -s ci-settings.xml \
                          -DaltDeploymentRepository=deploymentRepo::default::http://10.0.2.15:8081/repository/maven-releases/
                    '''
                }
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
