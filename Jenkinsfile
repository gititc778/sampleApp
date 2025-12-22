@Library('mySharedLibrary') _

def buildTag = ''

pipeline {
    agent { label 'build-agent' }

    parameters {
        string(name: 'APP_VERSION', defaultValue: '1.0.0', description: 'Application version')
        choice(name: 'ENVIRONMENT', choices: ['dev', 'staging', 'prod'], description: 'Deployment environment')
        string(name: 'BRANCH', defaultValue: 'main', description: 'Git branch to build')
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
                    // Use APP_VERSION directly or combine with timestamp
                    buildTag = "${params.APP_VERSION}-${generateTag()}"
                    echo "Generated Build Tag: ${buildTag}"
                }
            }
        }

        stage('Checkout Code') {
    steps {
        script {
            // Use your actual branch name here
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
                    // Ensure this function exists in your shared library
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
                    echo "Deploying Helm release: ${HELM_RELEASE} to namespace: ${K8S_NAMESPACE}"
                    helmDeploy(K8S_NAMESPACE, buildTag) // Shared library function
                }
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully!"
        }
        failure {
            echo "Pipeline failed. Check logs for details."
        }
    }
}

