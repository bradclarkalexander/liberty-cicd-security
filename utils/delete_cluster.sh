#!/bin/bash

export AWS_REGION=us-east-2
export AWS_DEFAULT_REGION=${AWS_REGION}
export ACCOUNT=$(aws sts get-caller-identity | grep Account | tr -d '":,' | awk '{print $2}')

CLUSTER="$(eksctl get cluster | grep liberty | awk '{print $1}')"

eksctl delete cluster --name ${CLUSTER}
