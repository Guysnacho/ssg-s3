# Home of Terraform Modules

After your initial setup there should be 3 or more files in here.

1. main.tf
   - This is Terraform's entry point into your project
   - You'll define workspace/organization names, terraform versions, and providers (AWS in this case) here
2. s3.tf
   - Configuration of your S3 bucket(s)
   - Hosts our site and provides a fallback bucket in case the first one is inaccessible
3. cloudfront.tf
   - Configuration of your CloudFront Distribution
   - Handles access control to our origin (S3) and caching behavior
4. db.tf
   - Configuration of your RDS Instance
   - Postgres backed RDS instance (with an aurora config commented out)
   - Stores our users, stock, and orders
5. vpc.tf
   - Configuration of your Virtual Private Cloud (VPC)
   - Cordons off network access to and from components
     - We kinda circumvent this by throwing our RDS instance in a public subnet though
6. *_lambda.tf
   - Configuration of a lambda
   - Used to handle dynamic actions kicked off by our site
7. gateway.tf
   - Configuration of our API Gateway
   - Routes HTTP requests from our site to our lambdas
8. outputs.tf
   - outputs that you'd like to have access to if your resources are updated
   - usually these are resource names or ARNs

