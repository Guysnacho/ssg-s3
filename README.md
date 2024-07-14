# Static Site Generation (SSG) meets AWS S3

This repo is to help me actually build this AWS course. Shouldn't be too hard ✨🥲

## Initial Plan

Monorepo

- Terraform Package
- Web package
- Github workflows with Smart builds
  - Applies after grep on repo
  - If changes in AWS package, apply tf apply first
  - Put [plan and apply](https://github.com/marketplace/actions/github-script#welcome-a-first-time-contributor) to PR
  - Deploy static package
- Look into [atmos](https://atmos.tools/) for environments

Setup

1. Signup for [Terraform HCP](https://app.terraform.io/public/signup/account)
2. Install tf cli
3. Build starter Next site
   1. Configure ssg export
4. Setup bucket, cloudfront, provider, outputs, whatever else locally
5. Setup workflow
6. Make it smart
