data "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "pipeline-artifacts-liberty"
}

resource "aws_codebuild_project" "fargate-profile" {
  name          = "fargate-profile"
  description   = "Create a fargate profile"
  service_role  = aws_iam_role.liberty-app-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "weaveworks/eksctl:0.71.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential{
        credential = var.dockerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
 }
 source {
     type   = "CODEPIPELINE"
     buildspec = file("buildspec/fargate-buildspec.yml")
 }
}

resource "aws_codebuild_project" "iam-policy" {
  name          = "create-iam-policy"
  description   = "Create a IAM role and ServiceAccount for the Load Balancer controller"
  service_role  = aws_iam_role.liberty-app-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "amazon/aws-cli"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential{
        credential = var.dockerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
 }
 source {
     type   = "CODEPIPELINE"
     buildspec = file("buildspec/aws-create-policy.yml")
 }
}

resource "aws_codebuild_project" "aws-load-balancer-controller" {
  name          = "aws-load-balancer-controller"
  description   = "CloudFormation template that creates an IAM role and attaches the IAM policy to it"
  service_role  = aws_iam_role.liberty-app-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    #image                       = "integrational/aws-eks-kube-docker-cli"
    image                       = "mreferre/eksutils"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential{
        credential = var.dockerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
 }
 source {
     type   = "CODEPIPELINE"
     buildspec = file("buildspec/aws-load-balancer-controller.yml")
 }
}

#resource "aws_codebuild_project" "lb-controller" {
#  name          = "lb-controller-setup"
#  description   = "Set up the lb controller"
#  service_role  = aws_iam_role.liberty-app-codebuild-role.arn
#
#  artifacts {
#    type = "CODEPIPELINE"
#  }
#
#  environment {
#    compute_type                = "BUILD_GENERAL1_SMALL"
#    image                       = "dtzar/helm-kubectl"
#    type                        = "LINUX_CONTAINER"
#    image_pull_credentials_type = "SERVICE_ROLE"
#    registry_credential{
#        credential = var.dockerhub_credentials
#        credential_provider = "SECRETS_MANAGER"
#    }
# }
# source {
#     type   = "CODEPIPELINE"
#     buildspec = file("buildspec/lb-buildspec.yml")
# }
#}


resource "aws_codebuild_project" "targetgroupbinding-crd" {
  name          = "targetgroupbinding-crd"
  description   = "Install the TargetGroupBinding CRDs"
  service_role  = aws_iam_role.liberty-app-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    #image                       = "jshimko/kube-tools-aws"
    image                       = "mreferre/eksutils"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential{
        credential = var.dockerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
 }
 source {
     type   = "CODEPIPELINE"
     buildspec = file("buildspec/targetgroupbinding-crd.yml")
 }
}

resource "aws_codebuild_project" "deploy-helm-chart" {
  name          = "deploy-helm-chart"
  description   = "Deploy the Helm chart from the Amazon EKS charts repo"
  service_role  = aws_iam_role.liberty-app-codebuild-role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "subhakarkotta/terraform-kubectl-helm-awscli"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"
    registry_credential{
        credential = var.dockerhub_credentials
        credential_provider = "SECRETS_MANAGER"
    }
 }
 source {
     type   = "CODEPIPELINE"
     buildspec = file("buildspec/deploy-helm-chart.yml")
 }
}

resource "aws_codepipeline" "cicd_pipeline" {

    name = "liberty-app-cicd"
    role_arn = aws_iam_role.liberty-app-codepipeline-role.arn

    artifact_store {
        type="S3"
        location = data.aws_s3_bucket.codepipeline_artifacts.id
    }

    stage {
        name = "Source"
        action{
            name = "Source"
            category = "Source"
            owner = "AWS"
            provider = "CodeStarSourceConnection"
            version = "1"
            output_artifacts = ["liberty-app-code"]
            configuration = {
                FullRepositoryId = "bradclarkalexander/liberty-cicd-security"
                BranchName   = "main"
                ConnectionArn = var.codestar_connector_credentials
                OutputArtifactFormat = "CODE_ZIP"
            }
        }
    }

    stage {
        name ="Fargate"
        action{
            name = "Build"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["liberty-app-code"]
            configuration = {
                ProjectName = "fargate-profile"
            }
        }
    }

#    stage {
#        name ="Approve"
#        action{
#            name = "Approval"
#            category = "Approval"
#            provider = "Manual"
#            version = "1"
#            owner = "AWS"
#        }
#    }

    stage {
        name ="IAMPolicy"
        action{
            name = "Build"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["liberty-app-code"]
            configuration = {
                ProjectName = "create-iam-policy"
            }
        }
    }

    stage {
        name ="AWSLoadBalancerControllerIAMPolicy"
        action{
            name = "Build"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["liberty-app-code"]
            configuration = {
                ProjectName = "aws-load-balancer-controller"
            }
        }
    }

    stage {
        name ="TargetGroupBindingCRD"
        action{
            name = "Deploy"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["liberty-app-code"]
            configuration = {
                ProjectName = "targetgroupbinding-crd"
            }
        }
    }

    stage {
        name ="DeployHelmChart"
        action{
            name = "Deploy"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["liberty-app-code"]
            configuration = {
                ProjectName = "deploy-helm-chart"
            }
        }
    }
}
