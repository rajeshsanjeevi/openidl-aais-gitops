resource "aws_iam_user" "baf_automation" {
  name = "${local.std_name}-baf-automation"
  force_destroy = true
  tags = merge(local.tags, { Name = "${local.std_name}-baf-automation", Node_type = var.node_type })
}
resource "aws_iam_access_key" "baf_automation_access_key" {
  user = aws_iam_user.baf_automation.name
  status = "Active"
}
resource "aws_iam_policy" "baf_eks_policy" {
  name        = "${local.std_name}-AmazonEKSAdminPolicy"
  description = "EKS Admin Policy for IAM user used by BAF automation"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "eks.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeNodegroup",
                "eks:ListNodegroups",
                "eks:DescribeCluster",
                "eks:ListClusters",
                "eks:AccessKubernetesApi",
                "ssm:GetParameter",
                "eks:ListUpdates",
                "eks:ListFargateProfiles"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ViewOwnUserInfo",
            "Effect": "Allow",
            "Action": [
                "iam:GetUserPolicy",
                "iam:ListGroupsForUser",
                "iam:ListAttachedUserPolicies",
                "iam:ListUserPolicies",
                "iam:GetUser"
            ],
            "Resource": [
                "arn:aws:iam::*:user/${local.std_name}-baf-automation"
            ]
        },
        {
            "Sid": "NavigateInConsole",
            "Effect": "Allow",
            "Action": [
                "iam:GetGroupPolicy",
                "iam:GetPolicyVersion",
                "iam:GetPolicy",
                "iam:ListAttachedGroupPolicies",
                "iam:ListGroupPolicies",
                "iam:ListPolicyVersions",
                "iam:ListPolicies",
                "iam:ListUsers"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "eks:UpdateClusterVersion",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:ListClusters"
            ],
            "Resource": "*"
        }
    ]
})
  tags = merge(local.tags, {Name = "${local.std_name}-AmazonEKSAdminPolicy", Node_type = var.node_type })
}
resource "aws_iam_user_policy_attachment" "baf_automation_policy_attach" {
  user       = aws_iam_user.baf_automation.name
  policy_arn = aws_iam_policy.baf_eks_policy.arn
}

