#!/bin/bash
aws logs tail /aws/lambda/"$1" --follow
