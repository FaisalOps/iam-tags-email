
#default tags for all resources created in this account

provider "aws"{

default_tags {
    tags = {
      owner = "Focusteck "  
      Name = "someone"
      environment = "dev"
      project = "Learning"
      automation-exclude = true
      pii = false

      
    }
  }
}


#created user

resource "aws_iam_user" "my_iam_user" {
  name = "test_user" # replace with user
  tags = {
    email = "test_user@somthing.com" # replace with user email
  }
}

#created group

resource "aws_iam_group" "my_user_group" {
  name = "DevOps_group"
}

#Trust Policy
resource "aws_iam_role" "my_assume_role" {
  name = "ec2-assume-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

# permission policy
resource "aws_iam_policy" "require_email_tag_on_create" {
  name = "RequireEmailTagOnCreatePolicy"

  policy = jsonencode({
    Version   = "2012-10-17",
    "Statement": [
		{
			"Sid": "DenyLambda",
			"Effect": "Deny",
			"Action": [
				"lambda:CreateFunction"
			],
			"Resource": [
				"*"
			],
			"Condition": {
				"Null": {
					"aws:RequestTag/email": "true"
				}
			}
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.my_assume_role.name
  policy_arn = aws_iam_policy.require_email_tag_on_create.arn
}


#attach policy

resource "aws_iam_user_policy_attachment" "my_iam_user_policy_attachment" {
  user       = aws_iam_user.my_iam_user.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

#policy to group

resource "aws_iam_group_policy_attachment" "my_iam_user_group_policy_attachment" {
  group      = aws_iam_group.my_user_group.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

# attach policy

resource "aws_iam_role_policy_attachment" "my_assume_role_policy_attachment" {
  role       = aws_iam_role.my_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBReadOnlyAccess"
}

#attach users to group

# Add user to group
resource "aws_iam_user_group_membership" "my_iam_user_group_membership" {
  user = aws_iam_user.my_iam_user.name
  groups = [aws_iam_group.my_user_group.name,]
}

#default tags to be added when creating resource or tags can be added at this stage

resource "aws_instance" "example" {
  ami           = "ami-066784287e358dad1"  # Amazon Linux
  instance_type = "t2.micro"
  subnet_id = "subnet-03e04455b9cdd1fc7"
  
  }
