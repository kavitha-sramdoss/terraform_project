# terraform_project
Terraform Project 

# Steps to create the infrastructure

1. Initiate the local directory containing the code to download all the plugins. When run for the first time, the overall time taken could depend on various factors such as internet speed, number of plugins based on the providers, modules if any,  that needs to be downloaded.
   
   *terraform init*

2. Run terraform plan to visualize the steps terraform would take to achieve the desired state. When executed for the first time, terrform would have no state to compare, hence the initial terraform plan will be quicker when compared to running plan while amending infrastructure.
   
   *terraform plan*
   
3. When the plan looks good, apply the changes. To override the default values 
