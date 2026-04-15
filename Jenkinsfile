@Library('my-shared-lib') _

def buildTag = ''

pipeline {
    agent any

    stages {

        stage('Generate Tag') {
            steps {
                script {
                    buildTag = generateTag()
                }
            }
        }

        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/gititc778/sampleApp.git', branch: 'master'
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

        stage('Deploy to AKS') {
            steps {
                script {
                    deployAKS(buildTag)
                }
            }
        }
    }
}