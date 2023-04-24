This is a small script to bring on-prem Database (only those data tables which are 2 months old) to AWS cloud postgresql server. 

1. Use jenkins setup and postgre setup folder to spin up ec2 instances with terraform and install jenkins and postgre inside ec2 with ansible.
2. Migration script is an ansible folder to run the script on prem server and aws ec2 instances to bring 2 months old database to cloud.
3. jenkinsFile builds a pipeline to deploy migration directory and sends notification for failure.

Make sure to change env specific data. Make sure VPN connection is running between on-prem and cloud. 
