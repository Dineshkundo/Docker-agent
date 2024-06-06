pipeline {
agent { dockerfile true }
    environment {
         GOOGLE_CREDENTIALS = credentials('json')  // manage jenkins -> credential -> king secrete text -> paste SA.Json.key
    }
    
    stages {
        stage('checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/SaravanaNani/Docker-agent.git'
            }
        }

        stage ('init') {
            steps{
                sh 'terraform init'
            }
        }
        stage ('validate') {
            steps{
                sh 'terraform validate'
            }
        }
        stage ('plan'){
            steps {
                sh 'terraform plan'
            }
        }
        stage ('action') {
            steps{
                sh 'terraform $action --auto-approve'
            }
        }
        stage ('instance wait time'){
            steps{
                script{
                    sleep(time: 60, unit: 'SECONDS') // Adjust the wait time as needed
                }
            }
        }
        stage('Setting inventory') {
            steps {
                sh '''
                private_ip=$(gcloud compute instances describe desk --zone us-west1-b --format='value(networkInterfaces[0].networkIP)')
                echo "[desk]" | sudo tee -a /etc/ansible/hosts
                echo "${private_ip}" | sudo tee -a /etc/ansible/hosts
                '''
            }
        }
        stage('update known hosts') {
            steps {
                script {
                    def privateIp = sh(script: 'gcloud compute instances describe desk --zone us-west1-b --format="value(networkInterfaces[0].networkIP)"', returnStdout: true).trim()
                    sh "echo 'jenkins ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/jenkins"
                    sh "sudo chown -R jenkins:jenkins /var/lib/jenkins/.ssh"
                    sh "ssh-keygen -f /var/lib/jenkins/.ssh/known_hosts -R ${privateIp} || true"
                    sh "ssh-keyscan -H ${privateIp} | sudo tee -a /var/lib/jenkins/.ssh/known_hosts"
                }
            }
        }        
        stage('Configure Ansible') {
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
        
        stage('ping') {
            steps {
                sh 'yes y | sudo ansible all -m ping -u root'
            }
        }
        
        stage ('playbook') {
            steps {
                script{
                     sh 'sudo ansible-playbook --inventory /etc/ansible/hosts /etc/ansible/playbook.yml'
                }
            }
        }
    }
}
