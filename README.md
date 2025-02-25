# Shopping list app
## Introduction

Shopping list is a simple web-app meant to help you communicate with your household to help get your shopping done faster.

## App description

App is written in python using flask module it also uses uwsgi proxy which then goes though nginx and information is written to the database using mysql database.

### App (Shopping list)
* App is a flask python based app in folder `/app`.
* It uses html templates `/app/templates` for front end.
* Also it uses uwsgi proxy to make it available for the internet.
* Configuration for uwsgi is in `/app/app.ini`

### Nginx
* Nginx acts a proxy server which gets all the traffic and redirects it to the app.
* It is the only container which is exposed to the internet at port 80.
* Nginx config file is `/nginx.conf`

### Database (Mysql)
* Mysql database collects all the data and makes it available for the app to function. 
* It is initialized with `/db_init/init.sql` file.

### Dockerfile
* Dockerfile makes an image for the app from python image.

### Docker-Compose
* Docker compose joins all 3 elements together app Db and Nginx server so the app would fully work. If you change mysql `user` or `user password` u also need to change it in the `/app/app.py` and `dockerfile`.

### Terraform
* Terrarorm is used to create a VPC with EC2 instance to deploy the app. 
* It uses backend to work with workflows and variables to select region and instance type.
* Terraform files are located in `./terraform/` directory.

### Ansible
* Ansible playbook is located in `/playbook.yaml`
* Ansible is using dynamic inventory named `/aws_ec2.yaml` which gets all the ec2 instances in the selected region. And configures them to run the app.



## Installiation
### Docker
1. You need to have docker compose installed on your system. [Docker compose Installation guide.](https://docs.docker.com/compose/install/)
2. Clone the repository.
3. Run `docker compose up --build`.
4. Connect to the app by typing `localhost` in browser.

### Amazon EC2
#### Steps for deploying on ec2 instance on amazon aws
* Terraform is using backend for it to properly work, so you will need to configure backend so it would work for you. For that you will need your own s3 bucket and dynamodb table.
* Disclamer it costs money. More info on that in amazon AWS website.
* Requirements for this is to have installed.
1. [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. [Have an AWS account.](https://aws.amazon.com/)
3. [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
4. [Ansible full package](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

* Installation
1. First you will need to configure `/terraform/backend.tf` file to change values.
2. You can change your region and instance type which will run the app in `/terraform/variables.tf`
3. Then in the folder `/terraform` run `terraform init` then `terraform apply --auto-approve`
4. Then change `./aws_ec2.yaml` region to which you changed `/terrform/variables.tf` file.
5. After terraform is done run `ansible-playbook -i aws_ec2.yaml playbook.yaml --private-key private_key.pem -u ubuntu` Replace `private_key.pem` with private key with your key which you can create in Amazon cli by running this command `aws ec2 create-key-pair \
    --key-name my-key-pair \
    --key-type rsa \
    --key-format pem \
    --query "KeyMaterial" \
    --output text > my-key-pair.pem`. Your private key wil be `my-key-pair.pem' in this example.
6. Find your instance dns name by running `ansible-inventory -i aws_ec2.yaml --list | grep public_dns_name | head -1`
7. Then copy it to your browser and connect to the app.