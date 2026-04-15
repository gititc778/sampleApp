def buildTag = ''

pipeline {
    agent { label 'build-agent' }

    parameters {
        string(name: 'BRANCH', defaultValue: 'master', description: 'Git branch to checkout')

        choice(
            name: 'NAMESPACE',
            choices: ['dev', 'qa'],
            description: 'K8s Namespace'
        )

        booleanParam(name: 'DEPLOY', defaultValue: true, description: 'Deploy to AKS?')
    }

    stages {
        stage('Generate Tag') {
            steps {
                script {
                    def date = new Date().format('yyyyMMdd')
                    buildTag = "${date}.${env.BUILD_NUMBER}"
                    currentBuild.displayName = buildTag

                    sh "echo BUILD_TAG=${buildTag} > build.env"
                }
            }
        }

        stage('Use Tag') {
            steps {
                script {
                    echo "The build tag is: ${buildTag}"
                }
            }
        }

        stage('Checkout Code') {
            steps {
                cleanWs()
                git url: 'https://github.com/gititc778/sampleApp.git', branch: "${params.BRANCH}"
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t sampleapp:${buildTag} ."
                }
            }
        }

        stage('Push to Docker Registry') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-login-itc', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        sh """
                            echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                            docker tag sampleapp:${buildTag} ${DOCKER_USER}/sampleapp:${buildTag}
                            docker push ${DOCKER_USER}/sampleapp:${buildTag}
                        """
                    }
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

        stage('Manual Approval') {
            steps {
                input message: 'Approve deployment to AKS?'
            }
        }

        stage('Deploy to AKS') {
            when {
                expression { params.DEPLOY }
            }
            steps {
                sh """
                     helm upgrade --install sampleapp ./helm/sampleapp \
                     --namespace ${params.NAMESPACE} \
                     --create-namespace \
                     --set image.tag=${buildTag}
                """
            }
        }
    }
}