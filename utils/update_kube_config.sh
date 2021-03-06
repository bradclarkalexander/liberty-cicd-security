#!/bin/bash

export AWS_REGION=us-east-2
export AWS_DEFAULT_REGION=${AWS_REGION}
export ACCOUNT=$(aws sts get-caller-identity | grep Account | tr -d '":,' | awk '{print $2}')

CLUSTER="$(eksctl get cluster | grep liberty | awk '{print $1}')"

aws eks update-kubeconfig --name ${CLUSTER} --role-arn arn:aws:iam::${ACCOUNT}:role/liberty-app-codebuild-role
