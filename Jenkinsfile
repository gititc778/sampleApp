@Library('mySharedLibrary') _

def buildTag = ''

pipeline {
    agent { label 'build-agent' }

    parameters {
        string(name: 'APP_VERSION', defaultValue: '1.0.0', description: 'Application version')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Deployment environment')
        booleanParam(name: 'DEPLOY', defaultValue: true, description: 'Deploy to Kubernetes')
    }

    environment {
        HELM_RELEASE = 'myapp'                 // Helm release name
        K8S_NAMESPACE = "${params.ENVIRONMENT}" // Kubernetes namespace
    }

    stages {

        stage('Generate Build Tag') {
            steps {
                script {
                    // Option 1: Use APP_VERSION directly
                    buildTag = "${params.APP_VERSION}"

                    // Option 2: Combine with timestamp for unique tag
                    // buildTag = "${params.APP_VERSION}-${generateTag()}"
                    
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
                    sonarScan() // Shared library function
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    buildDocker(buildTag) // Shared library function
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    pushDocker(buildTag) // Shared library function
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when { expression { params.DEPLOY } }
            steps {
                script {
                    input message: "Do you want to deploy to Kubernetes?", ok: "Deploy"
                    echo "Deploying Helm release: ${HELM_RELEASE} to namespace: ${K8S_NAMESPACE}"
                    helmDeploy(K8S_NAMESPACE, buildTag) // Shared library function
                }
            }
        }
    }
}
