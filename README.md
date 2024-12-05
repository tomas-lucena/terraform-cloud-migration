# Terraform Cloud Infrastructure Project

This project provides a modularized Terraform configuration to deploy a robust cloud infrastructure on AWS. It consists of multiple modules designed to provision and manage essential cloud resources, ensuring scalability, security, and high availability.

---

## Project Structure

The project is organized into the following modules:

1. **VPC** 
   Creates a Virtual Private Cloud (VPC) to serve as the foundational network layer.  

2. **Security** 
   Configures security groups to control inbound and outbound traffic for resources.  

3. **Network** 
   Sets up public and private subnets, enabling isolated and secure network design.  

4. **Route53 Zone** 
   Manages DNS zones for the application's domain.  

5. **ACM** 
   Provisions and manages SSL/TLS certificates for secure communication.  

6. **Database** 
   Deploys a managed database within private subnets, ensuring security and availability.  

7. **Load Balancer** 
   Configures an Application Load Balancer (ALB) for distributing traffic to application instances.  

8. **DNS** 
   Manages DNS records to route traffic to appropriate resources (e.g., ALB, database).  

9. **Application** 
   Deploys the application, integrates it with the load balancer, and secures it within private subnets.  


---

## Variables

The project uses several input variables. Below are the key variables and their descriptions:

| Variable                 | Description                                         |
|--------------------------|-----------------------------------------------------|
| `base_cidr_block`        | Base CIDR block for the VPC.                        |
| `region`                 | AWS region for resource deployment.                |
| `number_private_subnets` | Number of private subnets to create.                |
| `number_public_subnets`  | Number of public subnets to create.                 |
| `domain`                 | Domain name for the Route53 zone.                  |
| `ami_id`                 | AMI ID for application deployment.                 |

---

