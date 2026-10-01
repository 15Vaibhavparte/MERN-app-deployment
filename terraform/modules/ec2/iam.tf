


# IAM Role for EC2 instances
# Chnage "this" to a more descriptive name if needed, for example "ec2_role" or "jumpsever_role"

resource "aws_iam_role" "this" {
  name               = "${var.env}-${var.name}-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "custom_policies" {
  count      = length(var.iam_policy_arns)
  policy_arn = var.iam_policy_arns[count.index]
  role       = aws_iam_role.this.name
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.env}-${var.name}-profile"
  role = aws_iam_role.this.name
}