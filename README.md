Gitea, Grafana, and Authelia SSO Deployment with Nginx Reverse Proxy

This document outlines the steps to deploy and access the Gitea, Grafana, and Authelia application stack, using Docker, Nginx as a reverse proxy, Certbot for SSL certificates, and nip.io for subdomain mapping.
1. Prerequisites:-
- Before proceeding with the deployment, ensure you have the following prerequisites:

    1. Docker installed and running on the host machine.
    2. Docker Compose installed for managing multi-container applications.
    3. Nginx installed and configured as a reverse proxy.
    4. Certbot for obtaining SSL certificates.
    5. nip.io for subdomain mapping to the public IP address.. 

2. Clone the Repository on the server/local
3. Modification in configuration file according to the need :-
    1. authelia/config/configuration.yml       @ Authelia main configuration file
    2. authelia/config/users.yml               @ Authelia Users/Password file
    3. prometheus/prometheus.yml               @ Prometheus main confugtaion file with scrape-config, targets.
    4. promtail/promtail.conf                  @ promtail config for getting the logs and passing to loki
        
3. Make the container up 
    - docker-compose up -d
4. Create the nginx.conf file as like shared below:-

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


5. Setup SSL using Certbot
6. Accessing the Services
    1. Gitea - domain_name1.server_ip.nip.io;
    2. Grafana - domain_name2.server_ip.nip.io;
    3. Authelia - domain_name3.server_ip.nip.io;