 #!/bin/bash# Script de automatización para la VM

sudo apt-get update

sudo apt-get install -y docker.io

sudo systemctl start docker

sudo systemctl enable docker# Levantamos DVWA en segundo plano

sudo docker run -d -p 80:80 --name dvwa vulnerables/web-dvw 