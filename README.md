# Static Site Generation (SSG) meets AWS S3

[![🌱 Apply, Build, Deploy 🌿](https://github.com/Guysnacho/ssg-s3/actions/workflows/main.yml/badge.svg)](https://github.com/Guysnacho/ssg-s3/actions/workflows/main.yml)

This repo is to help me actually build this AWS course. ~Shouldn't be too hard~ This has and will continue to be a learning experience. Follow along, check the releases, make a fork, go crazy, but check the [Project Home](https://blackbelt-init.notion.site/) for more details. ✨

## Initial Plan

### Monorepo

- Terraform Package
- Web package
- Github workflows with Smart builds
  - Applies after grep on repo
  - If changes in AWS package, apply tf apply first
  - Put [plan output](https://github.com/marketplace/actions/github-script#welcome-a-first-time-contributor) in PR
  - Deploy static package
- Look into [atmos](https://atmos.tools/) for environments

### Local Setup

1. Signup for [Terraform HCP](https://app.terraform.io/public/signup/account)
2. Install [tf cli](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
3. Install [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
4. Build starter [Next](https://nextjs.org/) site
   1. [Configure ssg export](https://nextjs.org/docs/pages/building-your-application/deploying/static-exports)
5. Setup bucket, cloudfront, provider, outputs, whatever else locally
6. Setup workflow
7. Make it smart
