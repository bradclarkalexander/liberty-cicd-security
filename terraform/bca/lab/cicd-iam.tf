data "aws_caller_identity" "current" {}

resource "aws_iam_role" "bca-app-codepipeline-role" {
  name = "bca-app-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "bca-app-cicd-pipeline-policies" {
    statement{
        sid = ""
        actions = ["codestar-connections:UseConnection"]
        resources = ["*"]
        effect = "Allow"
    }
    statement{
        sid = ""
        actions = ["cloudwatch:*", "s3:*", "codebuild:*"]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "bca-app-cicd-pipeline-policy" {
    name = "bca-app-cicd-pipeline-policy"
    path = "/"
    description = "Pipeline policy"
    policy = data.aws_iam_policy_document.bca-app-cicd-pipeline-policies.json
}

resource "aws_iam_role_policy_attachment" "bca-app-cicd-pipeline-attachment" {
    policy_arn = aws_iam_policy.bca-app-cicd-pipeline-policy.arn
    role = aws_iam_role.bca-app-codepipeline-role.id
}


resource "aws_iam_role" "bca-app-codebuild-role" {
  name = "bca-app-codebuild-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "codebuild.amazonaws.com",
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

data "aws_iam_policy_document" "bca-app-cicd-build-policies" {
    statement{
        sid = ""
        actions = ["logs:*", "s3:*", "codebuild:*", "secretsmanager:*","iam:*"]
        resources = ["*"]
        effect = "Allow"
    }
}

resource "aws_iam_policy" "bca-app-cicd-build-policy" {
    name = "bca-app-cicd-build-policy"
    path = "/"
    description = "Codebuild policy"
    policy = data.aws_iam_policy_document.bca-app-cicd-build-policies.json
}

resource "aws_iam_role_policy_attachment" "bca-app-cicd-codebuild-attachment1" {
    policy_arn  = aws_iam_policy.bca-app-cicd-build-policy.arn
    role        = aws_iam_role.bca-app-codebuild-role.id
}

resource "aws_iam_role_policy_attachment" "bca-app-cicd-codebuild-attachment2" {
    policy_arn  = "arn:aws:iam::aws:policy/PowerUserAccess"
    role        = aws_iam_role.bca-app-codebuild-role.id
}
