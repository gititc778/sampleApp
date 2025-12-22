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
        HELM_RELEASE = 'myapp'
        K8S_NAMESPACE = "${params.ENVIRONMENT}"
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
<<<<<<< HEAD
    steps {
        git branch: 'master',
            url: 'https://github.com/pranathi0906/sampleApp.git',
            credentialsId: 'a6bd5f7f-0e56-4954-b433-e8751e51e0a8'
    }
}

=======
            steps {
                git branch: 'master',
                    url: 'https://github.com/pranathi0906/sampleApp.git',
                    credentialsId: 'a6bd5f7f-0e56-4954-b433-e8751e51e0a8'
            }
        }
>>>>>>> Added Jenkinsfile


        stage('SonarQube Analysis') {
            steps {
                script {
                    sonarScan()
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

        stage('Deploy to Kubernetes') {
            when { expression { params.DEPLOY } }
            steps {
                script {
                    input message: "Deploy to Kubernetes?", ok: "Deploy"
                    helmDeploy(K8S_NAMESPACE, buildTag)
                }
            }
        }
    }
}
