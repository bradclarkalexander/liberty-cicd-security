liberty-cicd-security
=====================

 

### With this repo we will;

 

-   Use Infrastructure as Code (terraform), and CI/CD (AWS CodePipeline) to
    launch EKS/Fargate container infrastructure on AWS.

 

-   Deploy a simple containerized application (based on deploying micro services
    to EKS Fargate
    [https://www.eksworkshop.com/beginner/180_fargate/](https://www.eksworkshop.com/beginner/180_fargate/)).

 

-   Integrate the Anchore open-source tool for deep analysis of the docker
    images.

 

Pre-requisites:
---------------

-   An AWS account with credentials and appropriate IAM roles/permissions

-   The pipeline pulls down the IAC repo from GitHub

-   S3 bucket for the TF State

-   Dockerhub credentials (to pull down terraform docker image)

-   Codestar Connector

 

Steps:
------

1.  Clone the repo, cd into repo base directory

2.  Bootstrap CodePipeline (cd bootstrap && terraform init && terraform apply)

    -   bootstrap creates:

        -   S3 buckets for tf state and pipeline artifacts

        -   Dynamo DB for terraform state locking
