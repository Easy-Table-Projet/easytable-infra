# 1️⃣ VPC 생성
# VPC는 격리된 네트워크 환경을 제공합니다.
resource "aws_vpc" "easytable_vpc" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "easytable-vpc"
  }
}

# 2️⃣ Subnet 생성
# 퍼블릭 서브넷: 인터넷과 직접 통신 가능한 영역
# 프라이빗 서브넷: 인터넷과 직접 통신할 수 없는 보안 영역
## 퍼블릭 서브넷 (2개, 서로 다른 AZ)
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.easytable_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "easytable-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.easytable_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-northeast-2b"
  map_public_ip_on_launch = true
  
  tags = {
    Name = "easytable-public-subnet-2"
  }
}

## 프라이빗 서브넷 (2개, 서로 다른 AZ)
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.easytable_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-2a"
  
  tags = {
    Name = "easytable-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.easytable_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-2b"
  
  tags = {
    Name = "easytable-private-subnet-2"
  }
}

# 3️⃣ 인터넷 게이트웨이 & 퍼블릭 서브넷의 라우팅 테이블
# IGW: VPC가 인터넷과 통신할 수 있게 해주는 게이트웨이
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.easytable_vpc.id
  
  tags = {
    Name = "easytable-igw"
  }
}

# 퍼블릭 서브넷용 라우팅 테이블
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.easytable_vpc.id
  
  tags = {
    Name = "easytable-public-rt"
  }
}

# 인터넷으로 가는 경로 추가
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

# 퍼블릭 서브넷에 라우팅 테이블 연결
resource "aws_route_table_association" "public_assoc_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

# 4️⃣ NAT Gateway 설정
# NAT Gateway: 프라이빗 서브넷의 리소스가 인터넷과 통신할 수 있게 해주는 게이트웨이
## Elastic IP 할당
resource "aws_eip" "nat_1" {
  domain = "vpc"
  
  tags = {
    Name = "easytable-nat-eip-1"
  }
}

resource "aws_eip" "nat_2" {
  domain = "vpc"
  
  tags = {
    Name = "easytable-nat-eip-2"
  }
}

## NAT Gateway 생성
resource "aws_nat_gateway" "nat_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_subnet_1.id
  
  tags = {
    Name = "easytable-nat-1"
  }
}

resource "aws_nat_gateway" "nat_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_subnet_2.id
  
  tags = {
    Name = "easytable-nat-2"
  }
}

## 프라이빗 서브넷용 라우팅 테이블
resource "aws_route_table" "private_1" {
  vpc_id = aws_vpc.easytable_vpc.id
  
  tags = {
    Name = "easytable-private-rt-1"
  }
}

resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.easytable_vpc.id
  
  tags = {
    Name = "easytable-private-rt-2"
  }
}

## NAT Gateway로 가는 라우트 추가
resource "aws_route" "private_nat_1" {
  route_table_id         = aws_route_table.private_1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_1.id
}

resource "aws_route" "private_nat_2" {
  route_table_id         = aws_route_table.private_2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_2.id
}

## 프라이빗 서브넷에 라우팅 테이블 연결
resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_1.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_2.id
}

# 5️⃣ AWS ECR 생성
# ECR: Docker 이미지를 저장하는 프라이빗 레지스트리
resource "aws_ecr_repository" "app_repo" {
  name = "easytable-app"
  
  tags = {
    Name = "easytable-ecr"
  }
}

# 6️⃣ Security Group 생성
# 보안 그룹: 트래픽을 제어하는 가상 방화벽
resource "aws_security_group" "ecs_sg" {
  name        = "easytable-ecs-sg"
  description = "Security group for EasyTable ECS tasks"
  vpc_id      = aws_vpc.easytable_vpc.id

  tags = {
    Name = "easytable-ecs-sg"
  }
}

# 인바운드 규칙: HTTP 트래픽 허용
resource "aws_security_group_rule" "ecs_allow_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  security_group_id = aws_security_group.ecs_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# 아웃바운드 규칙: 모든 트래픽 허용
resource "aws_security_group_rule" "ecs_allow_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.ecs_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}

# 7️⃣ DB 서브넷 그룹 (RDS용)
resource "aws_db_subnet_group" "easytable_db_subnet_group" {
  name       = "easytable-db-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
  
  tags = {
    Name = "easytable-db-subnet-group"
  }
}


# RDS를 위한 Security Group
resource "aws_security_group" "rds_sg" {
  name        = "easytable-rds-sg"
  description = "RDS security group for EasyTable"
  vpc_id      = aws_vpc.easytable_vpc.id

  tags = {
    Name = "easytable-rds-sg"
  }
}

# Redis를 위한 Security Group
resource "aws_security_group" "redis_sg" {
  name        = "easytable-redis-sg"
  description = "Redis security group for EasyTable"
  vpc_id      = aws_vpc.easytable_vpc.id

  tags = {
    Name = "easytable-redis-sg"
  }
}

# RDS Security Group Rules
resource "aws_security_group_rule" "rds_inbound" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_sg.id
  source_security_group_id = aws_security_group.ecs_sg.id
}

# Redis Security Group Rules 
resource "aws_security_group_rule" "redis_inbound" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis_sg.id
  source_security_group_id = aws_security_group.ecs_sg.id
}

# ECS에서 RDS로의 아웃바운드 규칙
resource "aws_security_group_rule" "ecs_to_rds_outbound" {
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.rds_sg.id
}

# ECS에서 Redis로의 아웃바운드 규칙
resource "aws_security_group_rule" "ecs_to_redis_outbound" {
  type                     = "egress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_sg.id
  source_security_group_id = aws_security_group.redis_sg.id
}


# 8️⃣ RDS (MySQL) 생성
resource "aws_db_instance" "rds" {
  identifier            = "easytable-db"
  engine                = "mysql"
  instance_class        = "db.t3.micro"
  allocated_storage     = 20
  db_name               = var.db_name
  username              = var.db_user
  password              = var.db_password
  publicly_accessible   = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name  = aws_db_subnet_group.easytable_db_subnet_group.name
  skip_final_snapshot   = true
  
  tags = {
    Name = "easytable-rds"
  }
}

# 9️⃣ ElastiCache 서브넷 그룹 생성
resource "aws_elasticache_subnet_group" "easytable_cache_subnet_group" {
  name       = "easytable-cache-subnet-group"
  subnet_ids = [
    aws_subnet.private_subnet_1.id,
    aws_subnet.private_subnet_2.id
  ]
  
  tags = {
    Name = "easytable-cache-subnet-group"
  }
}

# 🔟 Redis (ElastiCache) 생성
resource "aws_elasticache_cluster" "redis" {
  cluster_id          = "easytable-redis"
  engine              = "redis"
  node_type           = "cache.t3.micro"
  num_cache_nodes     = 1
  security_group_ids = [aws_security_group.redis_sg.id]
  subnet_group_name   = aws_elasticache_subnet_group.easytable_cache_subnet_group.name
  
  tags = {
    Name = "easytable-redis"
  }
}

# 1️⃣1️⃣ ECS 클러스터 및 서비스 생성
resource "aws_ecs_cluster" "ecs" {
  name = "easytable-cluster"
  
  tags = {
    Name = "easytable-ecs-cluster"
  }
}

# ECS Task 실행 역할
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# ECS Task 실행 역할에 정책 연결
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task 정의
resource "aws_ecs_task_definition" "app" {
  family                   = "easytable-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "512"
  cpu                      = "256"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = <<DEFINITION
  [
    {
      "name": "easytable",
      "image": "${aws_ecr_repository.app_repo.repository_url}:latest",
      "memory": 512,
      "cpu": 256,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8080,
          "hostPort": 8080,
          "protocol": "tcp"
        }
      ],
      "environment": [
        { "name": "SPRING_PROFILES_ACTIVE", "value": "dev" },
        { "name": "MYSQL_HOST", "value": "${split(":", aws_db_instance.rds.endpoint)[0]}" },
        { "name": "MYSQL_PORT", "value": "3306" },
        { "name": "MYSQL_DATABASE", "value": "${var.db_name}" },
        { "name": "MYSQL_USERNAME", "value": "${var.db_user}" },
        { "name": "MYSQL_PASSWORD", "value": "${var.db_password}" },
        { "name": "REDIS_HOST", "value": "${aws_elasticache_cluster.redis.cache_nodes[0].address}" },
        { "name": "REDIS_PORT", "value": "6379" }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/easytable",
          "awslogs-region": "ap-northeast-2",
          "awslogs-stream-prefix": "ecs",
          "awslogs-create-group": "true"
        }
      }
    }
  ]
  DEFINITION

  tags = {
    Name = "easytable-task-definition"
  }
}

# CloudWatch 로그 그룹 생성
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/easytable"
  retention_in_days = 30

  tags = {
    Name = "easytable-logs"
  }
}

# ECS Task Execution Role에 CloudWatch 로그 권한 추가
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_logs" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

# ECS 서비스 생성
resource "aws_ecs_service" "app_service" {
  name            = "easytable-service"
  cluster         = aws_ecs_cluster.ecs.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups = [aws_security_group.ecs_sg.id]
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.app_tg.arn
    container_name   = "easytable"
    container_port   = 8080
  }
  
  tags = {
    Name = "easytable-ecs-service"
  }
}





resource "aws_security_group" "alb_sg" {
  name        = "easytable-alb-sg"
  description = "Security group for EasyTable ALB"
  vpc_id      = aws_vpc.easytable_vpc.id

  # ALB가 80번 포트에서 트래픽을 받음
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 모든 인터넷에서 접근 가능
  }

  # ALB가 ECS로 요청을 보낼 때 모든 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "easytable-alb-sg"
  }
}


# 1️⃣2️⃣ ALB 생성
resource "aws_lb" "app_lb" {
  name               = "easytable-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]
  
  tags = {
    Name = "easytable-alb"
  }
}


# 1. ALB 타겟 그룹 생성
resource "aws_lb_target_group" "app_tg" {
  name        = "easytable-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.easytable_vpc.id
  target_type = "ip"

  health_check {
    path                = "/actuator/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    interval            = 30
    timeout             = 5
    matcher             = "200"
  }

  tags = {
    Name = "easytable-target-group"
  }
}

# 2. ALB 리스너 생성
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }

    depends_on = [aws_lb_target_group.app_tg]

}