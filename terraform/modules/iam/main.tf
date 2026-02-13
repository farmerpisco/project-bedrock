resource "aws_iam_user" "iam_user" {
  name = "bedrock-dev-view"
}

resource "aws_iam_user_policy_attachment" "readonly" {
  user       = aws_iam_user.iam_user.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_policy" "iam_put_bucket" {
  name        = "bedrock-assets-upload-policy"
  description = "Allow IAM user to upload objects to bedrock-assets-1570"
  policy      = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ]
        Resource = "${var.s3_bucket_arn}/*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_upload" {
  name       = "attach-upload-policy"
  policy_arn = aws_iam_policy.iam_put_bucket.arn
  users      = [aws_iam_user.iam_user.name]
}

resource "aws_iam_access_key" "credentials" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_login_profile" "credentials" {
  user                    = aws_iam_user.iam_user.name
  password_reset_required = false
}

# # Create an access entry to allow "developer user" to access the EKS cluster
# resource "aws_eks_access_entry" "pb_iam_user_view" {
#   cluster_name  = var.eks_cluster_name
#   principal_arn = aws_iam_user.iam_user.arn
#   type          = "STANDARD"
# }

# # Grant the "view" policy to "developer user"  - read-only access to cluster resources
# resource "aws_eks_access_policy_association" "pb_iam_user_view" {
#   cluster_name  = var.eks_cluster_name
#   principal_arn = aws_iam_user.iam_user.arn
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

#   access_scope {
#     type = "cluster"
#   }

#   depends_on = [aws_eks_access_entry.pb_iam_user_view]
# }