# terraform_project
Terraform Project 

# Steps to create the infrastructure

1. Initiate the local directory containing the code to download all the plugins. When run for the first time, the overall time taken could depend on various factors such as internet speed, number of plugins based on the providers, modules if any,  that needs to be downloaded.
   
   *terraform init*

2. Run terraform plan to visualize the steps terraform would take to achieve the desired state. When executed for the first time, terrform would have no state to compare, hence the initial terraform plan will be quicker when compared to running plan while amending infrastructure.
   
   *terraform plan*
   
3. When the plan looks good, apply the changes. Its recommended not to use --auto-approve to verify the plan before applying. 

   *terraform apply*

# Additional instructions
To override the default values either update the var file "myvar.auto.tfvars" or use --var "variable_name=value"

 Eg:  *terraform plan --var "root_volume_size=50" --var "ebs_size=40"*
 
 Eg:  *terraform apply --var "root_volume_size=50" --var "ebs_size=40"*
 
Variable precedence is terraform help in ensuring the reusability of the code. The same code can be replicated to create resources across environments by modifying the variable in the tfvars file myvar.auto.tfvars or for testing, one can use the --var option which takes the most precedence during resource creation. 

# SSH keys
While using the ssh keys, we are overring the default key specidied as part of the var.tf variable block definition "Instance_key01" to "Instance_key02" in myvar.auto.tfvar as it takes precedence over the default variable in the variable block. We can also have a key specified as part of the environmental variable as TF_VAR_variable_name. 

   Eg: *export TF_VAR_keys=Instance_key01*
   
The environmental variables are however the least preferred variables which are overridde by the default, tfvars, auto.tfvars or --var "variable=value" in their order of prefence. 
Apart from this option, we can also create a map of strings varilable for keys, where more than one valid keys can be specified and used in the main.tf depending on the requirement and called using the lookup function, but the variable precedence option works better here as it requires least intervention. 

# Approach & Challenges faced
1. Firstly, staring with the ssh keys, to ensure its as dynamic as possible, I first created the code where, when there are more than 1 ssh keys, the code would check if the keys are available first, and then use them. But, terraform however would always exit with "the invalid key error", if the key is not available in AWS. Even the attempt to nullify the error using *contains function* was not working as terrform always looked for a valid key that's available in the AWS account before the resource creation. Hence shifted the logic to variable precedence where we get the option to specify more than 1 ssh key by overriding the default one.
   
2. Second one was with dyamic shape selection. Given that most of my experience lies with OCI, I wasn't aware only a certain instance type in AWS support CPU core count modification. To be more specific, only the core count of the vCPU as part of the instance template can be modified, not the vCPU itself, or the memory. We must choose different instance types based on the requirement for different vCPU or memory values. AWS offers huge range of instance types where we can find a match on most occassion.

# State file Management
 Terraform's state files are the most critical files and for production, the state file must be stored either in a cloud object storage like aws s3 with dynamodb lock or terraform native cloud *Terraform Enterprise*. Terraform Enterprise offers multiple options of running terraform code within a workspace such as
   CLI driven - the most basic version of workspace for testing the code ensuring the state files are in a remote location. One can use the CLI driven workspace in scripted pipeline as well, but the API driven is most preferred. 
   VCS - Version Controlled System, when integrated with a version control (git) via webhook, a commit would trigger a build
   API driven - Trigger workflow using Terraform Enterprise API, best option to use with pipeline. 

# Access VM using ssh key
Use Instance_key02 to access the instance

*ssh -i "pem_key_path/Instance_key02.pem ubuntu@public_ip_addr*

Eg:  *ssh -i "C:\Users\kavitha\Downloads\Instance_key02.pem" ubuntu@65.2.178.145*

To check the disk sizes provisioned, execute below command

sudo fdisk -l | grep -B1 Elastic




