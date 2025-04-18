resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "github-actions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github_actions.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:*:*"
          }
        }
      }
    ]
  })
}

# Create custom policy for S3 bucket access
resource "aws_iam_policy" "s3_bucket_access" {
  name        = "github-actions-s3-access"
  description = "Policy allowing GitHub Actions to manipulate files in the steverhoton.com S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:GetBucketLocation"
        ]
        Resource = [
          "arn:aws:s3:::steverhoton.com",
          "arn:aws:s3:::steverhoton.com/*"
        ]
      }
    ]
  })
}

# Create custom policy for CloudFront cache invalidation
resource "aws_iam_policy" "cloudfront_invalidation" {
  name        = "github-actions-cloudfront-invalidation"
  description = "Policy allowing GitHub Actions to create CloudFront cache invalidations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetInvalidation",
          "cloudfront:ListInvalidations"
        ]
        Resource = [
          "arn:aws:cloudfront::*:distribution/E121HAZWT3OMVA"
        ]
      }
    ]
  })
}

# Create custom policy for Lambda function deployment
resource "aws_iam_policy" "lambda_deployment" {
  name        = "github-actions-lambda-deployment"
  description = "Policy allowing GitHub Actions to deploy and manage Lambda functions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:GetFunction",
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:ListVersionsByFunction",
          "lambda:PublishVersion",
          "lambda:CreateAlias",
          "lambda:UpdateAlias",
          "lambda:DeleteAlias",
          "lambda:GetAlias",
          "lambda:ListAliases",
          "lambda:AddPermission",
          "lambda:RemovePermission",
          "lambda:InvokeFunction",
          "lambda:GetPolicy"
        ]
        Resource = ["arn:aws:lambda:us-east-1:*:function:*"]
      },
      {
        Effect = "Allow"
        Action = [
          "lambda:ListFunctions",
          "lambda:ListTags",
          "lambda:TagResource",
          "lambda:UntagResource"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = ["*"]
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "lambda.amazonaws.com"
          }
        }
      }
    ]
  })
}

# Create custom policy for SQS queue management
resource "aws_iam_policy" "sqs_management" {
  name        = "github-actions-sqs-management"
  description = "Policy allowing GitHub Actions to create and manage SQS queues"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:CreateQueue",
          "sqs:DeleteQueue",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ListQueues",
          "sqs:ListQueueTags",
          "sqs:SetQueueAttributes",
          "sqs:TagQueue",
          "sqs:UntagQueue",
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:PurgeQueue"
        ]
        Resource = ["arn:aws:sqs:us-east-1:*:*"]
      }
    ]
  })
}

# Attach policies to the role as needed
resource "aws_iam_role_policy_attachment" "github_actions_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" # General read-only access
}

# Attach S3 bucket policy to the role
resource "aws_iam_role_policy_attachment" "github_actions_s3_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.s3_bucket_access.arn
}

# Attach CloudFront invalidation policy to the role
resource "aws_iam_role_policy_attachment" "github_actions_cloudfront_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.cloudfront_invalidation.arn
}

# Attach Lambda deployment policy to the role
resource "aws_iam_role_policy_attachment" "github_actions_lambda_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.lambda_deployment.arn
}

# Attach SQS management policy to the role
resource "aws_iam_role_policy_attachment" "github_actions_sqs_policy" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.sqs_management.arn
}

# Output the role ARN for use in GitHub Actions workflows
output "github_actions_role_arn" {
  value       = aws_iam_role.github_actions.arn
  description = "ARN of the IAM role for GitHub Actions"
}
