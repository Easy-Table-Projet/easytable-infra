#!/bin/bash

# 스크립트 실행 권한 확인
if [ ! -x "$(command -v docker)" ]; then
   echo "Error: docker가 설치되어 있지 않습니다."
   exit 1
fi

# 기존 컨테이너 확인 및 정리
echo "기존 컨테이너 확인 중..."
if [ "$(docker ps -q)" ]; then
    echo "실행 중인 컨테이너를 정리합니다..."
    docker compose down
    if [ $? -eq 0 ]; then
        echo "기존 컨테이너가 성공적으로 정리되었습니다."
    else
        echo "컨테이너 정리 중 오류가 발생했습니다."
        exit 1
    fi
fi

# terraform.tfvars 파일 존재 확인 및 변수 로드
if [ -f terraform.tfvars ]; then
   echo "기존 terraform.tfvars 파일이 있습니다."
   # tfvars 파일에서 변수 읽기
   aws_access_key=$(grep '^aws_access_key' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')
   aws_secret_key=$(grep '^aws_secret_key' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')
   db_name=$(grep '^db_name' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')
   db_user=$(grep '^db_user' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')
   db_password=$(grep '^db_password' terraform.tfvars | cut -d '=' -f2 | tr -d ' "')
   echo "terraform.tfvars 파일을 로드했습니다."
else
   echo "terraform.tfvars 파일이 없습니다! 변수를 수동으로 입력해야 합니다."
fi

# 필요한 변수가 없을 경우 입력 요청 함수
prompt_if_empty() {
   local var_name=$1
   local var_value=${!var_name}

   if [ -z "$var_value" ]; then
       read -sp "[$var_name] 값을 입력하세요: " input_value
       echo ""  # 새 줄 추가
       eval $var_name="$input_value"
   fi
}

# 필수 변수 체크 및 입력 요청
echo "변수 확인 중..."
prompt_if_empty "aws_access_key"
prompt_if_empty "aws_secret_key"
prompt_if_empty "db_name"
prompt_if_empty "db_user"
prompt_if_empty "db_password"

# 설정된 변수 확인 (보안 보호)
echo -e "\n변수 설정 상태:"
echo "aws_access_key: ${aws_access_key:0:4}****** (보안 보호)"
echo "aws_secret_key: ********** (보안 보호)"
echo "db_name: $db_name"
echo "db_user: $db_user"
echo "db_password: ********** (보안 보호)"

# 사용자 확인
read -p "위 설정으로 진행하시겠습니까? (y/n): " confirm
if [[ $confirm != "y" ]]; then
   echo "스크립트를 종료합니다."
   exit 1
fi

# terraform.tfvars 파일 생성
echo "terraform.tfvars 파일 생성 중..."
cat > terraform.tfvars << EOF
aws_access_key = "${aws_access_key}"
aws_secret_key = "${aws_secret_key}"
db_name = "${db_name}"
db_user = "${db_user}"
db_password = "${db_password}"
EOF
echo "terraform.tfvars 파일이 생성되었습니다."

# Docker Compose 실행
echo -e "\nDocker Compose 실행 중..."
docker compose up -d

# 실행 상태 확인
if [ $? -eq 0 ]; then
   echo "서비스가 성공적으로 시작되었습니다."
   docker compose ps
   
   echo -e "\nDocker 컨테이너에 접속합니다..."
   echo -e "\n테라폼 명령어 안내:"
   echo "1. terraform init   : 테라폼 초기화 및 프로바이더/모듈 다운로드"
   echo "2. terraform plan   : 변경 사항 미리보기 (실제 변경 X)"
   echo "3. terraform apply  : 실제 인프라 변경 사항 적용"
   echo "4. terraform destroy: 생성된 모든 인프라 삭제"
   echo -e "\n컨테이너에 접속합니다. 위 명령어들을 실행할 수 있습니다..."
   docker exec -it easytable-infra-terraform-1 sh
else
   echo "서비스 시작 중 오류가 발생했습니다."
   exit 1
fi