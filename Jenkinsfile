def buildTag = ''

pipeline {
    agent any

    stages {

        stage('Generate Tag') {
            steps {
                script {
                    def date = new Date().format('yyyyMMdd')    //local variable
                    buildTag = "${date}.${BUILD_NUMBER}"   //global variable. env=env variables in jenkins
                    currentBuild.displayName = buildTag        //The name you see in Jenkins UI will be modified with buildtag

                   
                    sh "echo BUILD_TAG=${buildTag} > build.env"
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
                sh 'docker build -t sampleapp:${buildTag} .'
            }
        }

        stage('Push to Docker Registry') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-login-itc', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                        docker tag sampleapp:${buildTag} ${DOCKER_USER}/sampleapp:${buildTag}
                        docker push ${DOCKER_USER}/sampleapp:${buildTag}
                    '''
                }
            }
        }

        stage('Deploy to Dev env') {
            steps {

                sh '''
                    export KUBECONFIG=/home/danish/kubeconfig/config.yaml

                    kubectl get ns
                    sed "s/IMAGE_TAG/${buildTag}/g" deployment.yaml | kubectl apply -f - -n dev
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
                    sed "s/IMAGE_TAG/${buildTag}/g" deployment.yaml | kubectl apply -f - -n prod
                '''
            }
        }


    }
}
