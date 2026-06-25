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
                withCredentials([usernamePassword(credentialsId: 'docker-login-itc', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker tag sampleapp:${BUILD_NUMBER} ${DOCKER_USER}/sampleapp:${BUILD_NUMBER}
                        docker push ${DOCKER_USER}/sampleapp:${BUILD_NUMBER}
                    '''
                }
            }
        }

        stage('Deploy to Dev env') {
            steps {

                sh '''
                    export KUBECONFIG=/home/danish/kubeconfig/config.yaml

                    kubectl get ns
                    sed "s/IMAGE_TAG/${BUILD_NUMBER}/g" deployment.yaml | kubectl apply -f - -n dev
                '''
            }
        }

        stage('Deploy to prod env') {
            steps {


                input(  
                    message: 'Deploy to Prod Environment?',
                    ok: 'Deploy'
                )


                sh '''
                    export KUBECONFIG=/home/danish/kubeconfig/config.yaml

                    kubectl get ns
                    sed "s/IMAGE_TAG/${BUILD_NUMBER}/g" deployment.yaml | kubectl apply -f - -n prod
                '''
            }
        }


    }
}
