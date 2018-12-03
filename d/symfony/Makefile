install:
	composer install --classmap-authoritative --no-scripts --no-dev
	APP_ENV=prod php bin/console cache:clear --no-debug --no-warmup
	APP_ENV=prod php bin/console cache:warmup

preview:
	sam local start-api --region us-east-2

deploy: install package upload
package:
	sam package \
        --template-file template.yaml \
        --output-template-file .cloudformation.yaml \
        --s3-bucket bref-bootstrap-benchmarks
upload:
	sam deploy \
        --template-file .cloudformation.yaml \
        --stack-name bref-bootstrap-d-symfony \
        --capabilities CAPABILITY_IAM \
        --region us-east-2
