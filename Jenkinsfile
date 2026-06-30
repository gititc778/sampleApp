def buildTag = ''

pipeline {
    agent { label 'build-agent-01' }

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
                git url: 'https://github.com/gititc778/sampleApp.git', branch: 'master'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('MySonarServer') {
                    sh '''
                        dotnet sonarscanner begin /k:"sampleapp"

                        dotnet build -c Release

                        dotnet sonarscanner end
                    '''
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
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