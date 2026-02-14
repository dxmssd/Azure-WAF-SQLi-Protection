Azure WAF: SQL Injection Protection & Perimeter Security
Project Overview
This project demonstrates a professional-grade security architecture deployed on Microsoft Azure using Terraform (IaC). The core objective is to protect a web application (DVWA) hosted in a private environment from common web vulnerabilities, specifically SQL Injection (SQLi), by implementing an Application Gateway with Web Application Firewall (WAF v2).
Key Features

- Infrastructure as Code (IaC): 100% automated deployment using Terraform.
- Perimeter Defense: WAF v2 in Prevention Mode using the OWASP 3.2 Core Rule Set (CRS).
- Zero Trust Management: Administrative access is restricted via Azure Bastion (no public SSH/RDP exposure).
- Network Segmentation: Isolated subnets for Gateway (WAF), Backend (Application), and Management (Bastion).

Technical Architecture

The infrastructure follows a multi-tier security design:
- Public Layer: Application Gateway (WAF) with a dedicated Public IP.
- Management Layer: Azure Bastion service for secure administrative access.
- Private Layer: Ubuntu 22.04 VM running DVWA inside a Docker container, reachable only through the WAF or Bastion.

 Tech Stack

- Cloud Provider: Microsoft Azure
- IaC Tool: Terraform
- Security Service: Azure Web Application Firewall (WAF v2)
- Virtualization: Docker
- Operating Systems: Ubuntu 22.04 LTS (Server) / CachyOS (Local Admin)
- Networking: Azure VNET, Subnets, and Network Security Groups (NSG)

Security Validation & Proof of Concept (PoC)
The Challenge

The Damn Vulnerable Web App (DVWA) is intentionally vulnerable to SQL Injection. Without protection, a simple payload like ' OR '1'='1 would expose the entire database.
The Defense (WAF in Action)

With the WAF configured in Prevention Mode, every request is inspected.

- Attack Simulation: An SQLi payload was sent to the public IP of the Gateway.
- WAF Response: The Application Gateway intercepted the malicious pattern and immediately returned a 403 Forbidden error.
- Result: The attack was dropped at the perimeter. Zero malicious traffic reached the backend VM.
- Status: 403 Forbidden - Microsoft-Azure-Application-Gateway/v2
<img width="916" height="1055" alt="image" src="https://github.com/user-attachments/assets/d4132c87-e021-4a57-8e87-bf1f614031ca" />



Monitoring & Logs

Real-time monitoring on the backend VM shows the WAF's Health Probes (10.0.1.x) constantly verifying the application's health, while external malicious attempts are absent from the local access logs.
How to Run

    Provision Infrastructure:
    Bash

    terraform init
    terraform apply -auto-approve

    Deploy Application:

        Access the VM via Bastion.

        Run the container: sudo docker run -d -p 80:80 vulnerables/web-dvwa

    Test:

        Access the WAF Public IP and attempt an SQLi attack.

👤 Author

Dante Manríquez Riquelme
Engineering Student in Informatics at INACAP
Specializing in Cloud Security, DevSecOps & Defensive Security
