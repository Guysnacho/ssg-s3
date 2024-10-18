# Static Site Generation (SSG) meets AWS S3

[![🌱 Apply, Build, Deploy 🌿](https://github.com/Guysnacho/ssg-s3/actions/workflows/main.yml/badge.svg)](https://github.com/Guysnacho/ssg-s3/actions/workflows/main.yml)

This repo is to help me actually build this AWS course. ~Shouldn't be too hard~ This has and will continue to be a learning experience. Follow along, check the releases, make a fork, go crazy, but check the [Project Home](https://blackbelt-init.notion.site/) for more details. ✨

## Project Layout

- Terraform Package
- Web package
- Github workflows
  - Applies terraform infra changes after commits to main branch
  - Bundles our app into static site files and a Docker image
  - Deploys uploads static site to S3 to be served by CloudFront
  - Uploads our Docker Image to the run context
  - Updates an SSM parameter's value to this artifact's URL
    - Important note - by default, an artifact upload will only live for 90 days. Keep this in mind if you want to roll changes back to a given date past that.

### Local Setup

1. Signup for [Terraform HCP](https://app.terraform.io/public/signup/account)
2. Install [tf cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
3. Install [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
4. Build starter [Next](https://nextjs.org/) site
   1. [Configure ssg export](https://nextjs.org/docs/pages/building-your-application/deploying/static-exports)
5. Setup bucket, cloudfront, provider, outputs, whatever else locally
6. Add GitHub action secrets
7. Test workflows
8. Sip water
