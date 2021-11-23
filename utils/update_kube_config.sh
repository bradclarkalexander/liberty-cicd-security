#!/bin/bash

export AWS_REGION=us-east-2
export AWS_DEFAULT_REGION=${AWS_REGION}

CLUSTER="$(eksctl get cluster | grep liberty | awk '{print $1}')"

aws eks update-kubeconfig --name ${CLUSTER}
