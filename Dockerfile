# Use an official Ubuntu as a parent image
FROM ubuntu:20.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages and dependencies
RUN apt-get update && \
    apt-get install -y git openjdk-17-jre wget vim sudo openssh-server software-properties-common && \
    apt-get clean

# Install Maven
RUN wget https://apache.osuosl.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz && \
    tar xzvf apache-maven-3.9.5-bin.tar.gz && \
    mv apache-maven-3.9.5 /opt && \
    echo 'export M2_HOME=/opt/apache-maven-3.9.5' >> /etc/profile && \
    echo 'export PATH=$M2_HOME/bin:$PATH' >> /etc/profile

# Install Ansible
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository --yes --update ppa:ansible/ansible && \
    apt-get install -y ansible

# Install Terraform
RUN wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    apt-get install -y terraform

# Create Jenkins user
RUN useradd -m -d /var/lib/jenkins -s /bin/bash jenkins && \
    echo 'jenkins:jenkins' | chpasswd && \
    echo 'jenkins ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Generate SSH key pair
RUN ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N "" && \
    mkdir -p /var/lib/jenkins/.ssh && \
    cp /root/.ssh/id_rsa.pub /var/lib/jenkins/.ssh/id_rsa.pub && \
    chown jenkins:jenkins /var/lib/jenkins/.ssh/id_rsa.pub && \
    chmod 644 /var/lib/jenkins/.ssh/id_rsa.pub && \
    cp /root/.ssh/id_rsa /var/lib/jenkins/.ssh/id_rsa && \
    chown jenkins:jenkins /var/lib/jenkins/.ssh/id_rsa && \
    chmod 600 /var/lib/jenkins/.ssh/id_rsa

# Expose SSH port
EXPOSE 22

# Start SSH service
CMD ["/usr/sbin/sshd", "-D"]
