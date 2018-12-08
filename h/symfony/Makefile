BOOTSTRAP_BENCHMARK_BUCKET ?= "bref-bootstrap-benchmarks"
.DEFAULT_GOAL := install
mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

permissions:
	chmod 755 ${current_dir}/bootstrap
	chmod -R u=rwX,g=rX,o=rX ${current_dir}/*

install:
	APP_ENV=prod composer install --classmap-authoritative --no-dev

preview:
	sam local start-api --region us-east-2

deploy: install permissions package upload
package:
	sam package \
        --template-file template.yaml \
        --output-template-file .cloudformation.yaml \
        --s3-bucket ${BOOTSTRAP_BENCHMARK_BUCKET}
upload:
	sam deploy \
        --template-file .cloudformation.yaml \
        --stack-name bref-bootstrap-h-symfony \
        --capabilities CAPABILITY_IAM \
        --region us-east-2
