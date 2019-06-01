# Hello aws-lambda-cpp!

Uses [aws-lambda-cpp](https://github.com/awslabs/aws-lambda-cpp) library to handle a request to an [AWS Lambda](https://aws.amazon.com/lambda/).

## Usage
1. Build lambda package as `hello.zip`.
2. Give necessary permissions.
3. Create lambda.
4. Invoke lambda.

### Build

```bash
make build-in-docker
```

### Give Permissions
```bash
aws iam create-role \
  --role-name lambda-cpp-demo \
  --assume-role-policy-document file://trust-policy.json

aws iam attach-role-policy --role-name lambda-cpp-demo --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole
```

### Create Lambda
```bash
aws lambda create-function \
  --function-name hello-world \
  --role arn:aws:iam::$AWS_ACCOUNT_ID:role/lambda-cpp-demo \
  --runtime provided \
  --timeout 15 \
  --memory-size 128 \
  --handler hello \
  --zip-file fileb://from_docker/hello.zip
```

### Invoke Lambda

``` bash
aws lambda invoke --function-name hello-world --payload '{ }' output.txt
```