data "aws_s3_bucket" "codepipeline_dockerbuild_artifacts" {
  bucket = "pipeline-artifacts-liberty"
}

resource "aws_codebuild_project" "docker-build" {
  name          = "docker-cicd-build"
  description   = "Build docker image"
  service_role  = aws_iam_role.tf-codebuild-role.arn
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    privileged_mode  		= true
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    #image_pull_credentials_type = "SERVICE_ROLE"
 }
 source {
     type   = "CODEPIPELINE"
     buildspec = file("buildspec/dockerbuild-buildspec.yml")
 }
}


resource "aws_codepipeline" "cicd_docker_pipeline" {

    name = "docker-cicd"
    role_arn = aws_iam_role.tf-codepipeline-role.arn

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
            output_artifacts = ["docker-code"]
            configuration = {
                FullRepositoryId = "bradclarkalexander/liberty-cicd-security"
                BranchName   = "main"
                ConnectionArn = var.codestar_connector_credentials
                OutputArtifactFormat = "CODE_ZIP"
            }
        }
    }

    stage {
        name ="Build"
        action{
            name = "Build"
            category = "Build"
            provider = "CodeBuild"
            version = "1"
            owner = "AWS"
            input_artifacts = ["docker-code"]
            configuration = {
                ProjectName = "docker-cicd-build"
            }
        }
    }
}
