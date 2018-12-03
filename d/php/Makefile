install:
	composer install --classmap-authoritative --no-scripts --no-dev

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
        --stack-name bref-bootstrap-d-php \
        --capabilities CAPABILITY_IAM \
        --region us-east-2
