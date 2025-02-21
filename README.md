## AWS 인프라 자동 배포 (Terraform + ECS + RDS + Redis)

이 프로젝트는 AWS의 ECS(Fargate), RDS(MySQL), Redis(ElastiCache), ALB를 Terraform을 사용하여 자동 배포하는 인프라 코드입니다.

### 1️⃣ `.env` 파일 생성 (AWS 자격 증명 및 DB 정보 설정)

```sh
echo 'AWS_ACCESS_KEY_ID="your-access-key"' >> .env
echo 'AWS_SECRET_ACCESS_KEY="your-secret-key"' >> .env
echo 'AWS_REGION="ap-northeast-2"' >> .env
echo 'DB_NAME="your-db-name"' >> .env
echo 'DB_USER="your-db-user"' >> .env
echo 'DB_PASSWORD="your-db-password"' >> .env
```
또는
```
AWS_ACCESS_KEY_ID="your-access-key"
AWS_SECRET_ACCESS_KEY="your-secret-key"
AWS_REGION="ap-northeast-2"
DB_NAME="your-db-name"
DB_USER="your-db-user"
DB_PASSWORD="your-db-password"
```



### 2️⃣ 실행 권한 부여 (한 번만 필요)

```sh
chmod +x script.sh
```

✅ **스크립트를 실행할 수 있도록 권한을 추가합니다.**

### 3️⃣ Terraform 실행 (AWS 인프라 배포)

```sh
./script.sh
```

✅ **Terraform이 자동으로 AWS 인프라를 생성합니다.**  
✅ **배포가 완료되면 `terraform output` 명령어로 ALB, RDS, Redis 엔드포인트를 확인할 수 있습니다.**

## Terraform 실행 후 확인할 것

Terraform이 성공적으로 실행되면 아래 정보를 확인하세요:

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

## Terraform 정리 (삭제)

인프라를 삭제하려면 다음 명령어를 실행하세요.

```sh
terraform destroy -auto-approve
```

✅ **AWS 리소스를 정리할 때 사용합니다.**

## 추가 개선 가능 사항

- **GitHub Actions & AWS CodePipeline을 활용한 자동 배포 설정**
- **ALB + HTTPS 설정 (Let’s Encrypt 인증서 적용)**
- **VPC 서브넷 구조 개선 (멀티 AZ 배포 고려)**

## ✅ 최종 정리

| 단계 | 실행 명령어 |
|------|------------|
| **환경변수 설정** | `echo 'AWS_ACCESS_KEY_ID="your-access-key"' >> .env` |
| **실행 권한 부여** | `chmod +x script.sh` |
| **Terraform 실행** | `./script.sh` |
| **배포된 정보 확인** | `terraform output` |
| **인프라 삭제** | `terraform destroy -auto-approve` |

🔥 **이제 Terraform을 실행하면 AWS 인프라가 자동으로 배포됩니다!** 🚀🔥  

