//before running pipeline make sure jenkins is installed with proper ansible plugins
pipeline {
  agent any

  stages {
    stage('Checkout code') {
      steps {
        git 'https://github.com/naziajahan/db_hybrid.git'
      }
    }

    stage('Install Ansible') {
      steps {
        sh 'sudo apt-get update && sudo apt-get install -y ansible'
      }
    }

    stage('Configure Ansible inventory') {
      steps {
        withCredentials([
          usernamePassword(credentialsId: 'onprem-credentials', usernameVariable: 'onprem_user', passwordVariable: 'onprem_password'),
          usernamePassword(credentialsId: 'aws-credentials', usernameVariable: 'aws_user', passwordVariable: 'aws_password')
        ]) {
          dir('migration') {
            sh 'echo "[onprem_db]\nonprem_server ansible_host=ONPREM_IP_ADDRESS ansible_user=${onprem_user} ansible_ssh_private_key_file=/path/to/private/key\n\n[aws_db]\naws_server ansible_host=AWS_IP_ADDRESS ansible_user=${aws_user} ansible_ssh_private_key_file=/path/to/private/key\n\n[all:vars]\nansible_python_interpreter=/usr/bin/python3\n\n[onprem_db:vars]\nonprem_password=${onprem_password}\n\n[aws_db:vars]\naws_password=${aws_password}\n" > inventory.ini'
          }
        }
      }
    }

    stage('Run Ansible playbook') {
      steps {
        dir('migration') {
          sh 'ansible-playbook -i inventory.ini playbook.yml'
        }
      }
    }

    stage('Failure') {
      steps {
        sh 'echo "Failed!"'
        slackSend channel: '#notifications',
          color: 'danger',
          message: "The pipeline has failed. Please check the logs: ${env.BUILD_URL}"
      }
      post {
        failure {
          mail body: "The pipeline has failed. Please check the logs: ${env.BUILD_URL}",
            from: 'jenkins@yourcompany.com',
            subject: 'Pipeline failed!',
            to: 'you@yourcompany.com'
        }
      }
    }
  }
}
