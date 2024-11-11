!/bin/bash

 Initialize Terraform
echo "Initializing Terraform…"
terraform init

 Check if terraform init was successful
if [ $? -eq 0 ]; then
    echo "Terraform initialization successful."
else
    echo "Terraform initialization failed."
    exit 1
fi

 Create a Terraform plan
echo "Creating Terraform plan…"
terraform plan -out=tfplan

 Check if terraform plan was successful
if [ $? -eq 0 ]; then
    echo "Terraform plan created successfully."
else
    echo "Failed to create Terraform plan."
    exit 1
fi

 Ask user if they want to apply the plan
echo "Do you want to apply this plan? (yes/no)"
read answer
if [ "$answer" == "yes" ]; then
    echo "Applying Terraform plan…"
    terraform apply "tfplan"
    if [ $? -eq 0 ]; then
        echo "Terraform apply successful."
    else
        echo "Terraform apply failed."
        exit 1
    fi
else
    echo "Apply cancelled."
fi