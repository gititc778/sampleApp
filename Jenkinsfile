pipeline {
    agent any

    environment {
        buildTag = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                git 'git@github.com:gititc778/sampleApp.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t sampleapp:${buildTag} .
                """
            }
        }

        stage('Push to Docker Registry') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'docker-login-itc',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )
                ]) {
                    sh """
                        echo "\${DOCKER_PASS}" | docker login -u "\${DOCKER_USER}" --password-stdin
                        docker tag sampleapp:${buildTag} \${DOCKER_USER}/sampleapp:${buildTag}
                        docker push \${DOCKER_USER}/sampleapp:${buildTag}
                    """
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                withCredentials([
                    file(
                        credentialsId: 'kubeconfig',
                        variable: 'KUBECONFIG'
                    )
                ]) {
                    sh """
                        sed -i "s/IMAGE_TAG/${buildTag}/g" deployment.yaml
                        kubectl apply -f deployment.yaml
                    """
                }
            }
        }
    }
}