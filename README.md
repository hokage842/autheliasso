
# Gitea, Grafana, and Authelia SSO Deployment with Nginx Reverse Proxy

This document outlines the steps to deploy and access the Gitea, Grafana, and Authelia application stack, using Docker, Nginx as a reverse proxy, Certbot for SSL certificates, and nip.io for subdomain mapping.
### Prerequisites:-
* Before proceeding with the deployment, ensure you have the following prerequisites:

    * Docker installed and running on the host machine.
    * Docker Compose installed for managing multi-container applications.
    * Nginx installed and configured as a reverse proxy.
    * Certbot for obtaining SSL certificates.
    * nip.io for subdomain mapping to the public IP address.. 

### Clone the Repository on the server/local
### Modification in configuration file according to the need :-
* authelia/config/configuration.yml       
* authelia/config/users.yml               
* prometheus/prometheus.yml              
* promtail/promtail.conf
        
### Make the container up 
    docker-compose up -d
### Create the nginx.conf file as like shared below:-

        server {
            server_name domain_name.server_ip.nip.io;
            location / {
                auth_request /authelia;
                auth_request_set $target_url $scheme://$http_host$request_uri;
                error_page 401 =302 http://localhost:9091/?rd=$target_url;
                proxy_pass http://localhost:service_port;  # Grafana server
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
            }

            location = /authelia {
                internal;
                proxy_pass http://localhost:9091/api/verify;
                proxy_set_header Content-Length "";
                proxy_pass_request_body off;
                proxy_set_header X-Original-URL $scheme://$http_host$request_uri;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            }

            location /authelia/ {
                proxy_pass http://localhost:9091/;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            }
        

        }


### Setup SSL using Certbot
### Accessing the Services
* Gitea - domain_name1.server_ip.nip.io;
* Grafana - domain_name2.server_ip.nip.io;
* Authelia - domain_name3.server_ip.nip.io; <br><br>


# Additional: Setting infra using terraform

### Requirements

* AWS CLI v2.25
* Terraform CLI v1.10

### Usage

* Create an IAM user with `AdministratorAccess` permissions and Create new Access key and Secret
* Configure AWS CLI with newly created credentials

```bash
aws configure --profile creato
aws sts get-caller-identity --profile creato
```

#### Create S3 Backend

Create a `bootstrap/terraform.tfvars` file by coping the `bootstrap/example.tfvars`

```bash
cd bootstrap
terraform init
terraform validate
terraform apply
```

This single S3 backend bucket will be used for all environments for this project.

Note: :warning: The `bootstrap` folder saves the state on local disk.

#### Create main infra

```bash
cd ..
terraform init
```

* Create a `terraform.tfvars` file in root folder by coping the `example.tfvars`
* :bulb: Ensure that the S3 Backend bucket name is same here

* Deploy main infra for `dev` environment

```bash
terraform workspace new dev
terraform workspace select dev
terraform validate
terraform plan
terraform apply
```

You can repeat the same for other environment like `prod`

```bash
terraform workspace new prod
terraform workspace select prod
terraform validate
terraform plan
terraform apply
```

:warning: Dont use `default` workspace