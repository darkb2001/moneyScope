# CI/CD (GitHub Actions)

## Workflows
- `ci.yml` - run on PR: checkout, build (Maven/Gradle), unit tests
- `deploy-auth.yml` - build docker image, push to ECR, update ECS service
- `deploy-transaction.yml` - same as above for transaction service
- `deploy-lambda.yml` - deploy BankConnector + Analytics using Serverless Framework or Terraform
- `deploy-frontend.yml` - build Next.js and publish to Amplify

## Example deploy step (auth service)
```yaml
- name: Build docker
  run: docker build -t moneyscope/auth:latest .
- name: Login to ECR
  uses: aws-actions/amazon-ecr-login@v2
- name: Push
  run: |
    docker tag moneyscope/auth:latest ${{ secrets.ECR_REGISTRY }}/moneyscope/auth:latest
    docker push ${{ secrets.ECR_REGISTRY }}/moneyscope/auth:latest
- name: Update ECS
  run: aws ecs update-service --cluster moneyscope-cluster --service auth-service --force-new-deployment
```
