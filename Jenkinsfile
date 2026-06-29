pipeline {
    agent { label 'build-agent-01' }

    
    parameters {
        string(name: 'BRANCH', defaultValue: 'master')
        choice(name: 'ENV', choices: ['dev', 'staging', 'prod'])
        booleanParam(name: 'DEPLOY', defaultValue: true)
    }
    
    environment {
        ENV = 'prod'  
    }



    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/gititc778/sampleApp.git', branch: "${params.BRANCH}"
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
                    sh """
                        echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker tag sampleapp:${BUILD_NUMBER} ${DOCKER_USER}/sampleapp:${BUILD_NUMBER}
                        docker push ${DOCKER_USER}/sampleapp:${BUILD_NUMBER}
                    """
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                input(
                    message: 'Deploy to Minikube?',
                    ok: 'Deploy'
                )

                sh """
                    export KUBECONFIG=/home/danish/kubeconfig/config.yaml

                    kubectl get ns

                    sed 's/IMAGE_TAG/${BUILD_NUMBER}/g' deployment.yaml | kubectl apply -f - -n devops
                """
            }
        }
    }
}
