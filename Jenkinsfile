pipeline {
    agent any

    environment {
        AWS_PROFILE = 'default'
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/kevalohith/terraform-workspace.git'
            }
        }

        stage('Setup AWS Credentials') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'AWS_CREDENTIALS', usernameVariable: 'AWS_ACCESS_KEY', passwordVariable: 'AWS_SECRET_KEY')]) {
                    sh '''
                    mkdir -p ~/.aws
                    echo "[default]" > ~/.aws/credentials
                    echo "aws_access_key_id = $AWS_ACCESS_KEY" >> ~/.aws/credentials
                    echo "aws_secret_access_key = $AWS_SECRET_KEY" >> ~/.aws/credentials
                    chmod 600 ~/.aws/credentials
                    '''
                }
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform init
                    terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Fetch Public IP & Create Inventory') {
            steps {
                script {
                    def public_ip = sh(script: "terraform output -json | jq -r '.public_ip'", returnStdout: true).trim()
                    if (!public_ip || public_ip == "null") {
                        error "Failed to fetch public IP. Check Terraform output."
                    }
                    writeFile file: 'ansible/inventory', text: "[webserver]\n${public_ip} ansible_user=ubuntu"
                }
            }
        }

        stage('Run Ansible Playbook') {
            steps {
                sh '''
                ansible-playbook -i ansible/inventory ansible/playbook.yml
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline execution completed."
        }
        failure {
            echo "Pipeline failed. Check the logs for errors."
        }
    }
}

