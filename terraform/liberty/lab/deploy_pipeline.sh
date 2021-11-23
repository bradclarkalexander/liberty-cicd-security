#!/usr/bin/env bash
set -exo pipefail

if [ -z "${AWS_DEFAULT_REGION}" ] || [ -z "$AWS_REGION" ]; then
	echo "AWS REGION NOT SET!!, defaulting to us-east-2"
	export AWS_DEFAULT_REGION=us-east-2
	export AWS_REGION=us-east-2
fi

terraform init
terraform apply -auto-approve  
