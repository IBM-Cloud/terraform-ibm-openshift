infrastructure:
	# Get the modules, create the infrastructure.
	terraform init && terraform get && terraform apply --target=ibm_compute_ssh_key.ssh_key_openshift --target=random_id.ose_name --target=module.network --target=module.sg --target=module.masternode --target=module.infranode --target=module.appnode --target=module.templates
	terraform init && terraform get && terraform apply --target=module.lbaas_app --target=module.lbaas_infra --parallelism=1

bastion:

	# Register the System with redhat
	terraform init && terraform get && terraform apply --target=module.setup_bastion
	
	# Install all the rpms and docker images required by the openshift
	cat ./scripts/setup_bastion_http.sh | ssh -o TCPKeepAlive=yes -o ServerAliveInterval=50 -o StrictHostKeyChecking=no -A root@$$(terraform output bastion_public_ip)
	

openshift:
	
	# Get the modules, for the pre install steps.
	terraform init && terraform get && terraform apply --target=module.pre_install
	

	# Install openshift
	scp -o StrictHostKeyChecking=no ./templates/inventory.cfg root@$$(terraform output bastion_public_ip):/root/
	ssh -o TCPKeepAlive=yes -o ServerAliveInterval=50 -o StrictHostKeyChecking=no root@$$(terraform output bastion_public_ip) 'ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml'
	ssh -o TCPKeepAlive=yes -o ServerAliveInterval=50 -o StrictHostKeyChecking=no -A root@$$(terraform output bastion_public_ip) 'ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml'
	
	# Get the modules, for the pre install steps.
	terraform init && terraform get && terraform apply --target=module.post_install

destroy:
	terraform init && terraform get && terraform destroy --target=module.lbaas_app --target=module.lbaas_infra --parallelism=1
	terraform init && terraform get && terraform destroy