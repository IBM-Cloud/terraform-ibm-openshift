infrastructure:
	# Get the modules, create the infrastructure.
	terraform init && terraform get && terraform apply

prepare-nodes:
	@read -p "Enter path to private key file to communicate with bastion machines:" file_path; \
	scp $$file_path root@$$(terraform output bastion_public_ip):~/.ssh/id_rsa
	# Add our identity for ssh, add the host key to avoid having to accept the
	# the host key manually. Also add the identity of each node to the bastion.
	ssh -A root@$$(terraform output bastion_public_ip) "ssh-keyscan -t rsa $$(terraform output master_private_ip)  >> ~/.ssh/known_hosts"
	ssh -A root@$$(terraform output bastion_public_ip) "ssh-keyscan -t rsa $$(terraform output infra_private_ip)  >> ~/.ssh/known_hosts"
	ssh -A root@$$(terraform output bastion_public_ip) "ssh-keyscan -t rsa $$(terraform output app_private_ip)  >> ~/.ssh/known_hosts"
	#update the /etc/hosts file and copy to all nodes
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "echo $$(terraform output master_private_ip) $$(terraform output master_host) $$(terraform output master_hostname)>> /etc/hosts" 
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "echo $$(terraform output infra_private_ip) $$(terraform output infra_host) $$(terraform output infra_hostname)>> /etc/hosts"
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "echo $$(terraform output app_private_ip) $$(terraform output app_host) $$(terraform output app_hostname)>> /etc/hosts"
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "echo $$(terraform output bastion_public_ip) $$(terraform output bastion_hostname).$$(terraform output bastion_domain) $$(terraform output bastion_hostname)>> /etc/hosts"
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- /etc/hosts $$(terraform output master_private_ip) /etc/hosts" < scripts/copy_file_bastion_nodes.sh
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s --  /etc/hosts $$(terraform output infra_private_ip) /etc/hosts" < scripts/copy_file_bastion_nodes.sh
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- /etc/hosts $$(terraform output app_private_ip) /etc/hosts" < scripts/copy_file_bastion_nodes.sh
	#Prepare the master and nodes for the openshift install
	chmod 755 scripts/update_bastion_address.sh
	sh scripts/update_bastion_address.sh $$(terraform output bastion_public_ip) scripts/ose.repo
	sh scripts/update_bastion_address.sh $$(terraform output bastion_public_ip) scripts/update_nodes.sh
	scp scripts/ose.repo root@$$(terraform output bastion_public_ip):~
	scp scripts/update_nodes.sh root@$$(terraform output bastion_public_ip):~
	scp scripts/disable_subscription.sh root@$$(terraform output bastion_public_ip):~
	
	#copy repo files
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- ose.repo $$(terraform output master_private_ip) /etc/yum.repos.d/ose.repo" < scripts/copy_file_bastion_nodes.sh
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- ose.repo $$(terraform output infra_private_ip) /etc/yum.repos.d/ose.repo" < scripts/copy_file_bastion_nodes.sh
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- ose.repo $$(terraform output app_private_ip) /etc/yum.repos.d/ose.repo" < scripts/copy_file_bastion_nodes.sh

	#Disable suscription on nodes
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- $$(terraform output master_private_ip) disable_subscription.sh" < scripts/remote_exe.sh
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- $$(terraform output infra_private_ip) disable_subscription.sh" < scripts/remote_exe.sh
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- $$(terraform output app_private_ip) disable_subscription.sh" < scripts/remote_exe.sh
	#Update the nodes
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- $$(terraform output master_private_ip) update_nodes.sh" < scripts/remote_exe.sh
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- $$(terraform output infra_private_ip) update_nodes.sh" < scripts/remote_exe.sh
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- $$(terraform output app_private_ip) update_nodes.sh" < scripts/remote_exe.sh