#!/bin/bash

eksctl delete fargateprofile --cluster "$(eksctl get cluster | grep liberty | awk '{print $1}')"  --name liberty-app 
