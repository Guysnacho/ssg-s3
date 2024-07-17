# Home of Terraform Modules

After your initial setup there should be 3 or more files in here.

1. main.tf
   - This is Terraform's entry point into your project
   - You'll define workspace/organization names, terraform versions, and providers (AWS in this case) here
2. s3.tf
   - Configuration of your S3 bucket
3. outputs.tf
   - outputs that you'd like to have access to if your resources are updated
   - usually these are resource names or ARNs
