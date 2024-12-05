
# resource "aws_instance" "server" {
#   ami                         = var.ami_id
#   instance_type               = "t2.micro"
#   key_name                    = "tomas"
#   subnet_id                   = var.private_subnets_id[0]
#   security_groups             = [var.sg_application_id]
#   associate_public_ip_address = true

#   tags = {
#     Name = "tf_server"
#   }
# }

resource "aws_iam_role" "ecs_role" {
  name = "tf_ecs_role"


  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "ecs-tasks.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })
}


resource "aws_iam_policy" "ecs_policy" {
  name        = "tf_ecs_policy"
  description = "tf_ecs_policy"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:GetAuthorizationToken",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ],
        "Resource" : "*"

      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:GetLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "events:PutRule",
          "events:PutTargets",
          "logs:CreateLogGroup"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "events:DescribeRule",
          "events:ListTargetsByRule",
          "logs:DescribeLogGroups"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "PutOnly",
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "*"
      }

    ]
  })
}


resource "aws_iam_role_policy_attachment" "role_ecs_exectuiton_attach" {
  role       = aws_iam_role.ecs_role.name
  policy_arn = aws_iam_policy.ecs_policy.arn
}

resource "aws_ecs_cluster" "cluster" {
  name = "tf_application_cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "tf_application_cluster"
  }

}


resource "aws_ecs_service" "ecs_service" {
  name            = "tf_ecs_service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.application.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnets_id
    security_groups  = [var.sg_application_id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = "application"
    container_port   = 8000
  }

  tags = {
    Name = "tf_ecs_service"
  }
}


resource "aws_cloudwatch_log_group" "ecsLogs" {
  name = "/ecs/ecsLogs"
}


resource "aws_ecs_task_definition" "application" {
  family                   = "service"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.ecs_role.arn

  container_definitions = jsonencode([
    {
      name      = "application"
      essential = true
      image     = "975050200917.dkr.ecr.us-east-1.amazonaws.com/playground/app-example:437b97776766984d638991418ee1cbbc4502a2bf"
      environment = [
        {
          "name" : "CONFIG_ENV",
          "value" : "config.Production"
        }
      ],
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "/ecs/ecsLogs",
          "awslogs-region" : "us-east-1",
          "awslogs-stream-prefix" : "ecs"
        }
      }
    }


  ])

  #   volume {
  #     name      = "service-storage"
  #     host_path = "/ecs/service-storage"
  #   }

  #   placement_constraints {
  #     type       = "memberOf"
  #     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #   }
}



