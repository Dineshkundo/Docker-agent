pipeline {
    agent {
        label 'docker-agent'
    }
    environment {
        ANSIBLE_INVENTORY_PATH = "/var/lib/jenkins/inventory.ini"
    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Dineshkundo/Docker-agent.git'
            }
        }
        stage('Desktop-tfm-init') {
            steps {
                sh '''
                cd /var/lib/jenkins/workspace/pipeline-1/terraform-Desk
                terraform init
                '''
            }
        }
        stage('Desktop-tfm-plan') {
            steps {
                sh '''
                cd /var/lib/jenkins/workspace/pipeline-1/terraform-Desk
                terraform plan
                '''
            }
        }
        stage('Desktop-tfm-action') {
            steps {
                sh '''
                cd /var/lib/jenkins/workspace/pipeline-1/terraform-Desk
                terraform $action --auto-approve
                '''
            }
        }
        stage('Create-Inventory-File') {
            when {
                expression { return action != 'destroy' }
            }
            steps {
                script {
                    sh '''
                    sudo touch ${ANSIBLE_INVENTORY_PATH}
                    private_ip=$(gcloud compute instances describe desk --zone us-east1-d --format='value(networkInterfaces[0].networkIP)')
                    echo "[desktop]" | sudo tee -a ${ANSIBLE_INVENTORY_PATH}
                    echo "${private_ip}" | sudo tee -a ${ANSIBLE_INVENTORY_PATH}
                    '''
                }
            }
        }
        stage('Configure Ansible') {
            when {
                expression { return action != 'destroy' }
            }
            steps {
                script {
                    sh '''
                    if ! grep -q "^[defaults]" /etc/ansible/ansible.cfg; then
                        echo "[defaults]" | sudo tee -a /etc/ansible/ansible.cfg
                    fi

                    echo 'host_key_checking = False' | sudo tee -a /etc/ansible/ansible.cfg
                    '''
                }
            }
        }
        stage('instance wait time for 60 seconds') {
            when {
                expression { return action != 'destroy' }
            }
            steps{
                script{
                    sleep(time: 60, unit: 'SECONDS')
                }
            }
        }
        stage('Conf-Desktop-server') {
            when {
                expression { return action != 'destroy' }
            }
            steps {
                sh 'ansible-playbook -i /var/lib/jenkins/inventory.ini playbook.yml -u root'
            }
        }
    }
}
