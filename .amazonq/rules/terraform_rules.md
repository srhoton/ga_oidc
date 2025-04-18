Any AWS resources need to be created using Terraform, and linted using `terraform validate` and `terraform fmt -check`.
Terraform code should be stored in a directory named `terraform` at the root of the repository.
State should be stored in S3 in the bucket called 'srhoton-tfstate', in a folder called 'ga-oidc'. 
The backend configuration should be stored in a file named `backend.tf` in the `terraform` directory.
All AWS resources should be created in the us-east-1 region.
