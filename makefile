infrastructure:
	# Get the modules, create the infrastructure.
	terraform init && terraform get && terraform apply

bastion:

	# Register the System with redhat
	ssh -o StrictHostKeyChecking=no -A root@$$(terraform output bastion_public_ip) 'bash -s' < ./scripts/rhn_register.sh $(rhn_username) $(rhn_password)
	
	# Install all the rpms and docker images required by the openshift
	cat ./scripts/setup_bastion_http.sh | ssh -o StrictHostKeyChecking=no -A root@$$(terraform output bastion_public_ip)
	

openshift:
	
	# Prepare the master , infra and app nodes
	@read -p "Enter path to private key file for bastion to  ssh to nodes:" file_path; \
	scp $$file_path root@$$(terraform output bastion_public_ip):~/.ssh/id_rsa
	# Add our identity for ssh, add the host key to avoid having to accept the
	# the host key manually. Also add the identity of each node to the bastion.
	ssh -A root@$$(terraform output bastion_public_ip) "ssh-keyscan -t rsa $$(terraform output master_private_ip)  >> ~/.ssh/known_hosts"
	ssh -A root@$$(terraform output bastion_public_ip) "ssh-keyscan -t rsa $$(terraform output infra_private_ip)  >> ~/.ssh/known_hosts"
	ssh -A root@$$(terraform output bastion_public_ip) "ssh-keyscan -t rsa $$(terraform output app_private_ip)  >> ~/.ssh/known_hosts"
	
	#update the /etc/hosts file and copy to all nodes
	scp scripts/hosts root@$$(terraform output bastion_public_ip):~
	ssh -o StrictHostKeyChecking=no -A root@$$(terraform output bastion_public_ip) 'cat hosts >> /etc/hosts'
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- /etc/hosts $$(terraform output master_private_ip) /etc/hosts" < scripts/copy_file_bastion_nodes.sh
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s --  /etc/hosts $$(terraform output infra_private_ip) /etc/hosts" < scripts/copy_file_bastion_nodes.sh
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- /etc/hosts $$(terraform output app_private_ip) /etc/hosts" < scripts/copy_file_bastion_nodes.sh
	
	#Prepare the master and nodes for the openshift install
	scp scripts/ose.repo root@$$(terraform output bastion_public_ip):~
	scp scripts/update_nodes.sh root@$$(terraform output bastion_public_ip):~
	scp scripts/disable_subscription.sh root@$$(terraform output bastion_public_ip):~
	scp scripts/post_install_master.sh root@$$(terraform output bastion_public_ip):~
	scp scripts/post_install_node.sh root@$$(terraform output bastion_public_ip):~

	#copy repo files
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- ose.repo $$(terraform output master_private_ip) /etc/yum.repos.d/ose.repo" < scripts/copy_file_bastion_nodes.sh
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- ose.repo $$(terraform output infra_private_ip) /etc/yum.repos.d/ose.repo" < scripts/copy_file_bastion_nodes.sh
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- ose.repo $$(terraform output app_private_ip) /etc/yum.repos.d/ose.repo" < scripts/copy_file_bastion_nodes.sh

	#Update the nodes
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- $$(terraform output master_private_ip) update_nodes.sh" < scripts/remote_exe.sh
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- $$(terraform output infra_private_ip) update_nodes.sh" < scripts/remote_exe.sh
	ssh -o StrictHostKeyChecking=no -A root@$$(terraform output bastion_public_ip) "bash -s -- $$(terraform output app_private_ip) update_nodes.sh" < scripts/remote_exe.sh

	# Update bastion node	
	cat ./scripts/prepare_bastion.sh | ssh -o StrictHostKeyChecking=no -A root@$$(terraform output bastion_public_ip)

	# Install openshift
	scp ./templates/inventory.cfg root@$$(terraform output bastion_public_ip):/root/
	ssh root@$$(terraform output bastion_public_ip) 'ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml'
	ssh root@$$(terraform output bastion_public_ip) 'ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml'
	
	# Execute the post install script on master
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- $$(terraform output master_private_ip) post_install_master.sh" < scripts/remote_exe.sh

	# Execute the post install script on nodes
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- $$(terraform output infra_private_ip) post_install_node.sh" < scripts/remote_exe.sh
	ssh -o StrictHostKeyChecking=no  -A root@$$(terraform output bastion_public_ip) "bash -s -- $$(terraform output app_private_ip) post_install_node.sh" < scripts/remote_exe.sh
