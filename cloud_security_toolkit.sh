#!/bin/bash

### Cloud Security Assessment and Enhancement Toolkit ###
### Author: AV10V ### 

# Global Variables
LOG_FILE="cloud_security_assessment_$(date +%F).log"
REPORT_FILE="cloud_security_report_$(date +%F).txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function: Log messages
log_message() {
    echo -e "$1" | tee -a "$LOG_FILE"
}

# Function: Check prerequisites
check_prerequisites() {
    log_message "${BLUE}Checking prerequisites...${NC}"
    command -v aws &>/dev/null || { log_message "${RED}AWS CLI is not installed. Please install it first.${NC}"; exit 1; }
    command -v az &>/dev/null || { log_message "${RED}Azure CLI is not installed. Please install it first.${NC}"; exit 1; }
    log_message "${GREEN}All prerequisites are met.${NC}"
}

# Function: Choose Cloud Provider
choose_provider() {
    echo "Choose your cloud provider:"
    echo "1. AWS"
    echo "2. Azure"
    read -rp "Enter the number (1 or 2): " provider
    case $provider in
        1) CLOUD_PROVIDER="AWS";;
        2) CLOUD_PROVIDER="Azure";;
        *) log_message "${RED}Invalid choice. Please select 1 or 2.${NC}"; exit 1;;
    esac
    log_message "${GREEN}Selected Cloud Provider: $CLOUD_PROVIDER${NC}"
}

# AWS Functions
aws_check_iam_permissions() {
    log_message "${BLUE}Checking AWS IAM Permissions...${NC}"
    aws iam list-users --output table | tee -a "$REPORT_FILE"
    log_message "${GREEN}AWS IAM Permissions check completed.${NC}"
}

aws_check_storage_security() {
    log_message "${BLUE}Checking AWS S3 Bucket Security...${NC}"
    aws s3api list-buckets --query "Buckets[].Name" --output text | while read -r bucket; do
        echo "Bucket: $bucket"
        aws s3api get-bucket-acl --bucket "$bucket"
    done | tee -a "$REPORT_FILE"
    log_message "${GREEN}AWS S3 Bucket Security check completed.${NC}"
}

aws_check_network_config() {
    log_message "${BLUE}Checking AWS Network Configurations...${NC}"
    aws ec2 describe-security-groups --output table | tee -a "$REPORT_FILE"
    log_message "${GREEN}AWS Network Configurations check completed.${NC}"
}

# Azure Functions
azure_check_iam_permissions() {
    log_message "${BLUE}Checking Azure IAM Permissions...${NC}"
    az ad user list --output table | tee -a "$REPORT_FILE"
    log_message "${GREEN}Azure IAM Permissions check completed.${NC}"
}

azure_check_storage_security() {
    log_message "${BLUE}Checking Azure Storage Account Security...${NC}"
    az storage account list --output table | tee -a "$REPORT_FILE"
    log_message "${GREEN}Azure Storage Account Security check completed.${NC}"
}

azure_check_network_config() {
    log_message "${BLUE}Checking Azure Network Configurations...${NC}"
    az network nsg list --output table | tee -a "$REPORT_FILE"
    log_message "${GREEN}Azure Network Configurations check completed.${NC}"
}

# Function: Main logic
run_checks() {
    if [[ $CLOUD_PROVIDER == "AWS" ]]; then
        aws_check_iam_permissions
        aws_check_storage_security
        aws_check_network_config
    elif [[ $CLOUD_PROVIDER == "Azure" ]]; then
        azure_check_iam_permissions
        azure_check_storage_security
        azure_check_network_config
    fi
}

# Main Script Execution
clear
log_message "${YELLOW}Cloud Security Assessment Script - Starting...${NC}"

# Check for prerequisites
check_prerequisites

# Choose the cloud provider
choose_provider

# Run the checks
run_checks

log_message "${GREEN}Assessment completed. Logs saved to $LOG_FILE and report saved to $REPORT_FILE.${NC}"
log_message "${YELLOW}Happy Securing Your Cloud!${NC}"
