pipeline {
    agent any
    parameters {
        string(name: 'ENVIRONMENT', defaultValue: 'dev', description: 'Enter workspace (dev, staging, prod)')
    }
    environment {
        AWS_PROFILE = 'default'
    }
    stages {
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
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/kevalohith/terraform-workspace.git'
            }
        }
        stage('Terraform Init & Apply') {
            steps {
                dir('terraform') {
                    sh '''
                    terraform init
                    terraform apply -auto-approve -var="environment=${WORKSPACE}"
                    terraform workspace select $ENVIRONMENT || terraform workspace new $ENVIRONMENT
                    terraform apply -auto-approve
                    '''
                }
            }
        }
        stage('Fetch Public IP & Create Inventory') {
            steps {
                script {
                    def public_ip = sh(script: "terraform output -json | jq -r '.public_ip'", returnStdout: true).trim()
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
}

