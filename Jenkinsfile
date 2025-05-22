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
                sh 'docker build -t sampleapp:${BUILD_NUMBER} .'
            }
        }

        stage('Push to Docker Registry') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker tag sampleapp:latest ${DOCKER_USER}/sampleapp:${BUILD_NUMBER}
                        docker push ${DOCKER_USER}/sampleapp:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Deploy to Kubernetes'){
            steps {
                withCredentials([file(credentialsId: 'kubeconfig-creds', variable: 'KUBECONFIG')]) {
                sh '''
                    kubectl set image deployment/sampleapp sampleapp=${DOCKER_USER}/sampleapp:${BUILD_NUMBER} -n dev
                '''
                }
            }
        }
    }
}