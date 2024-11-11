#!/usr/bin/env python3

import argparse
import boto3
from botocore.exceptions import ClientError
from azure.identity import DefaultAzureCredential
from azure.mgmt.resource import ResourceManagementClient

### AWS: Install the boto3 library. Azure: Install azure-identity and azure-mgmt-resource. ### 
### To audit IAM permissions in AWS: python cloud_security_audit.py --provider aws --scan iam ###
### To check storage security configurations in Azure: python cloud_security_audit.py --provider azure --scan storage ###
### Author : AV10V ###

def check_aws_iam():
    """Checks AWS IAM configuration for user permissions and attached policies."""
    print("Checking AWS IAM...")
    try:
        iam_client = boto3.client('iam')
        users = iam_client.list_users()['Users']
        for user in users:
            username = user['UserName']
            policies = iam_client.list_attached_user_policies(UserName=username)['AttachedPolicies']
            print(f"User {username} has policies: {[policy['PolicyName'] for policy in policies]}")
    except ClientError as e:
        print(f"AWS IAM error: {e}")

def check_aws_s3_security():
    """Checks AWS S3 bucket security configurations for ACL and public access settings."""
    print("Checking AWS S3 bucket security...")
    try:
        s3_client = boto3.client('s3')
        buckets = s3_client.list_buckets()['Buckets']
        for bucket in buckets:
            bucket_name = bucket['Name']
            acl = s3_client.get_bucket_acl(Bucket=bucket_name)
            print(f"Bucket {bucket_name} ACL: {acl}")
    except ClientError as e:
        print(f"AWS S3 error: {e}")

def check_aws_network():
    """Checks AWS network security group configurations and rules."""
    print("Checking AWS network configurations...")
    try:
        ec2_client = boto3.client('ec2')
        security_groups = ec2_client.describe_security_groups()['SecurityGroups']
        for sg in security_groups:
            print(f"Security Group {sg['GroupName']} rules: {sg['IpPermissions']}")
    except ClientError as e:
        print(f"AWS Network error: {e}")

def check_azure_iam():
    """Checks Azure IAM configuration for role assignments and policies."""
    print("Checking Azure IAM...")
    credential = DefaultAzureCredential()
    resource_client = ResourceManagementClient(credential, '<Your-Azure-Subscription-ID>')
    # Add code here to retrieve role assignments or access policies in Azure.

def check_azure_storage():
    """Checks Azure storage account security configurations (e.g., Blob Storage access)."""
    print("Checking Azure storage configurations...")
    # Add code to inspect Blob storage or other Azure storage settings.

def check_azure_network():
    """Checks Azure network security configurations such as NSGs and firewall rules."""
    print("Checking Azure network configurations...")
    # Add code for inspecting network security groups and other Azure network settings.

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Cloud Security Audit Script")
    parser.add_argument("--provider", choices=["aws", "azure"], required=True, help="Cloud provider: aws or azure")
    parser.add_argument("--scan", choices=["iam", "storage", "network"], required=True, help="Scan type: iam, storage, or network")

    args = parser.parse_args()
    
    if args.provider == "aws":
        if args.scan == "iam":
            check_aws_iam()
        elif args.scan == "storage":
            check_aws_s3_security()
        elif args.scan == "network":
            check_aws_network()
    elif args.provider == "azure":
        if args.scan == "iam":
            check_azure_iam()
        elif args.scan == "storage":
            check_azure_storage()
        elif args.scan == "network":
            check_azure_network()
