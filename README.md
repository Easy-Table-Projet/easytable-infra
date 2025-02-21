# AWS 인프라 자동 배포 (Terraform + ECS + RDS + Redis)

이 프로젝트는 **Terraform**을 사용하여 **AWS 인프라를 자동으로 배포**하는 코드입니다.
**ECS(Fargate), RDS(MySQL), Redis(ElastiCache), ALB** 등의 AWS 리소스를 한 번의 실행으로 설정할 수 있습니다.

---

## 🔑 1. 실행 권한 부여 (한 번만 필요)

스크립트를 실행할 수 있도록 실행 권한을 부여합니다.

```sh
chmod +x script.sh
```

✅ **이 작업은 한 번만 수행하면 됩니다.**

---

## 🛠 2. Terraform 변수 설정 (`terraform.tfvars` 파일 생성)

Terraform을 실행하기 전에 **`terraform.tfvars`** 파일을 먼저 생성해야 합니다.

프로젝트 루트 디렉토리에 `terraform.tfvars` 파일을 만들고 다음 내용을 입력하세요:

```plaintext
aws_access_key = ""
aws_secret_key = ""
db_name = ""
db_user = ""
db_password = ""
```

**위 파일에 AWS 자격 증명 및 데이터베이스 정보를 입력하세요.**

---

## 🚀 3. Terraform 실행 (AWS 인프라 배포)

아래 명령어를 실행하여 AWS 인프라를 자동으로 배포하세요.

```sh
./script.sh
```

✅ **Docker 컨테이너가 실행된 후 자동으로 Terraform 환경에 접속됩니다.**
✅ **컨테이너 내부에서 아래 명령어를 실행하여 Terraform 배포를 진행하세요:**

```sh
terraform init
terraform plan
terraform apply -auto-approve
```

✅ **배포가 완료되면 `terraform output` 명령어로 생성된 리소스 정보를 확인할 수 있습니다.**

---

## 🔍 4. Terraform 실행 후 확인할 정보

Terraform 실행 후, 아래 명령어를 입력하여 배포된 정보를 확인하세요.

```sh
terraform output
```

출력 예시:

```plaintext
alb_dns = "http://my-app-lb-1234567890.ap-northeast-2.elb.amazonaws.com"
rds_endpoint = "mydatabase.abcdefghijkl.ap-northeast-2.rds.amazonaws.com"
redis_endpoint = "my-redis.abcdefghijkl.ap-northeast-2.cache.amazonaws.com"
```

✅ **ALB DNS를 브라우저에서 열어보면 서비스가 정상적으로 배포되었는지 확인할 수 있습니다.**  
✅ **애플리케이션에서 RDS와 Redis를 사용할 때 해당 엔드포인트를 연결하세요.**

---

## 🛑 5. Terraform 정리 (AWS 리소스 삭제)

배포된 AWS 리소스를 삭제하려면 다음 명령어를 실행하세요.

```sh
terraform destroy -auto-approve
```

✅ **이 명령어를 실행하면 모든 AWS 리소스가 삭제됩니다.**

---

## 🔧 추가 개선 가능 사항

🚀 프로젝트를 더 발전시키기 위해 다음 기능을 추가할 수 있습니다.

- **GitHub Actions & AWS CodePipeline**을 활용한 CI/CD 자동 배포
- **ALB + HTTPS 설정** (Let’s Encrypt 인증서 적용)
- **VPC 서브넷 구조 개선** (멀티 AZ 배포 고려)
- **Terraform 모듈화** (재사용 가능한 구성)

---

## ✅ 최종 정리 (명령어 요약)

| 단계                | 실행 명령어                               |
|---------------------|---------------------------------------|
| **실행 권한 부여**  | `chmod +x script.sh`                 |
| **Terraform 변수 설정** | `terraform.tfvars` 파일 생성 후 정보 입력 |
| **Terraform 실행**  | `./script.sh`                        |
| **컨테이너 내부 Terraform 실행** | `terraform init && terraform apply -auto-approve` |
| **배포된 정보 확인** | `terraform output`                    |
| **인프라 삭제**     | `terraform destroy -auto-approve`    |

🔥 **Terraform을 실행하면 AWS 인프라가 자동으로 배포됩니다!** 🚀🔥

