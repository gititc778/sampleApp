pipeline {
    agent { label 'build-agent' }

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

        stage('Login to Azure and AKS') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aks-login', usernameVariable: 'AZURE_CLIENT_ID', passwordVariable: 'AZURE_CLIENT_SECRET')]) {
                    sh """
                        az logout || true
                        az login --service-principal \
                                 -u "$AZURE_CLIENT_ID" \
                                 -p "$AZURE_CLIENT_SECRET" \
                                 --tenant 2b32b1fa-7899-482e-a6de-be99c0ff5516

                        az aks get-credentials \
                            --resource-group rg-dev-flux \
                            --name aks-ne-itc-01 \
                            --overwrite-existing

                        kubelogin convert-kubeconfig -l azurecli

                        kubectl get pods -n default
                    """
                }
            }
        }

        stage('Deploy to AKS') {
            steps {
                sh """
                    sed 's/IMAGE_TAG/${BUILD_NUMBER}/g' deployment.yaml | kubectl apply -f -
                """
            }
        }
    }
}