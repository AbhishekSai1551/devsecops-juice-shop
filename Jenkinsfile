pipeline{
    agent any {
    environment {
        IMAGE_NAME = "my-juice-shop"
        IMAGE_TAG = "${env.BUILD_ID}"
    }
    stages{
        stage('Build Docker Image') {
            steps{
                echo 'Building the Juice shop Image'
                sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
            }
        }
        stage('Checkov Kubernetes scan') {
            steps{
                echo 'Scanning Kubernetes YAML manifests for misconfigs ...'
                sh "checkov -d . --framework kubernetes || true"
            }
        }
        stage('Trivy Vulnerability Scan ') {
            steps{
                echo 'Scan new docker images for Critical vulnerabilities'
                sh "trivy image --severity CRITICAL --exit-code 1 ${IMAGE_NAME}:${IMAGE_TAG}"
            }
        }
    }
    post{
        always {
            sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG} || true"
        }
        success {
            echo 'Pipeline succeeded! Image is secure'
        }
        failure {
            echo 'Pipeline failed! Security vulnerabilities were detected'
        }
    }
}   