# AWS Command Line Interface with Ruby Docker Image ([Dockerfile](https://github.com/vladgh/docker_base_images/tree/master/awscliruby))
[![](https://images.microbadger.com/badges/image/vladgh/awscliruby.svg)](https://microbadger.com/images/vladgh/awscliruby "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vladgh/awscliruby.svg)](https://microbadger.com/images/vladgh/awscliruby "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/vladgh/awscliruby.svg)](https://microbadger.com/images/vladgh/awscliruby "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/vladgh/awscliruby.svg)](https://microbadger.com/images/vladgh/awscliruby "Get your own license badge on microbadger.com")

Docker image with the AWS Command Line Interface and Ruby installed.

Optional variables :
- `AWS_ACCESS_KEY_ID` (or functional IAM profile)
- `AWS_SECRET_ACCESS_KEY` (or functional IAM profile)
- `AWS_DEFAULT_REGION` (defaults to 'us-east-1')

## Run command examples:

- Simple
```
docker run -it \
  -e AWS_ACCESS_KEY_ID=1234 \
  -e AWS_SECRET_ACCESS_KEY=5678 \
  vladgh/awscliruby aws --version
```

- Provide the .aws config folder
```
docker run -it \
  -v ~/.aws:/root/.aws \
  vladgh/awscliruby aws --version
```

- Describe an EC2 instance
```
docker run \
  -e AWS_ACCESS_KEY_ID=1234 \
  -e AWS_SECRET_ACCESS_KEY=5678 \
  -e AWS_DEFAULT_REGION=us-west-2 \
  vladgh/awscliruby \
  aws ec2 describe-instances --instance-ids i-1234
```

## AWS Command Line Reference
http://docs.aws.amazon.com/cli/latest/reference/