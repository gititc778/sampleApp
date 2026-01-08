@Library('mySharedLibrary') _

def buildTag = ''

pipeline {
    agent { label 'build-agent' }

    parameters {
        string(name: 'APP_VERSION', defaultValue: '1.0.0', description: 'Application version')
        choice(name: 'ENV', choices: ['dev', 'staging', 'prod'], description: 'Deployment environment')
        booleanParam(name: 'DEPLOY', defaultValue: true, description: 'Deploy to Kubernetes')
    }

    environment {
        HELM_RELEASE = 'userapp-release'
        K8S_NAMESPACE = "${params.ENV}"
        SONAR_PROJECT_KEY = 'sampleapp'
        SONAR_HOST_URL = 'http://20.75.196.235:9000/'
    }

    stages {

        stage('Generate Build Tag') {
            steps {
                script {
                    buildTag = "${params.APP_VERSION}-${generateTag()}"
                    echo "Generated Build Tag: ${buildTag}"
                }
            }
        }

        stage('Checkout Code') {
            steps {
                script {
                    def branchToBuild = params.BRANCH ?: 'master'
                    git branch: branchToBuild,
                        url: 'https://github.com/pranathi0906/sampleApp.git',
                        credentialsId: 'a6bd5f7f-0e56-4954-b433-e8751e51e0a8'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool name: 'mysonarscanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                    withSonarQubeEnv('sonarkube-swathi') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                -Dsonar.sources=. \
                                -Dsonar.host.url=${SONAR_HOST_URL} \
                                -Dsonar.login=$SONAR_AUTH_TOKEN
                        """
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    buildDocker(buildTag)
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    pushDocker(buildTag)
                }
            }
        }

        stage('Azure Login & AKS Setup') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aks-login',
                    usernameVariable: 'AZURE_CLIENT_ID',
                    passwordVariable: 'AZURE_CLIENT_SECRET'
                )]) {
                    sh """
                        az login --service-principal -u "$AZURE_CLIENT_ID" -p "$AZURE_CLIENT_SECRET" --tenant 2b32b1fa-7899-482e-a6de-be99c0ff5516
                        az aks get-credentials --resource-group rg-dev-flux --name aks-dev-flux-cluster --overwrite-existing
                        kubectl get pods -n default
                    """
                }
            }
        }

        stage('Create Helm Chart') {
            steps {
                script {
                    if (!fileExists('helm-chart/Chart.yaml')) {
                        sh 'helm create helm-chart'
                    }
                }
            }
        }

        stage('Deploy with Helm') {
            when { expression { params.DEPLOY } }
            steps {
                sh """
                    echo "Deploying Helm chart to AKS..."
                    helm upgrade --install ${HELM_RELEASE} ./helm-chart \
                        --namespace ${params.ENV} \
                        --set image.tag=${params.APP_VERSION} \
                        --create-namespace
                """
            }
        }
    } // end stages
} // end pipeline

    