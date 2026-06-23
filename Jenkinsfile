pipeline {
    agent any

    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/gititc778/sampleApp.git', branch: 'master'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t sampleapp:v10.6 .'
            }
        }

        stage('Push to Docker Registry') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-login-itc', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker tag sampleapp:v10.5 ${DOCKER_USER}/sampleapp:v10.6
                        docker push ${DOCKER_USER}/sampleapp:v10.6
                    '''
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                sh '''
                    export KUBECONFIG=/home/danish/kubeconfig/config.yaml

                    kubectl get ns
                    kubectl apply -f deployment.yaml -n devops
                '''
            }
        }

    }
}
