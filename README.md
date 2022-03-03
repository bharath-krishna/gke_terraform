This is a repository for creating GKE cluster and few applications via terraform.

clone this repository and create a ```terraform.tfvars.json``` file with the values for the variables listed in variables_*.tf files. A sample json file is also added with dummy data.

How to deploy,

> terraform plan
> terraform apply -auto-approve

Destroy
> terraform destroy -auto-approve
