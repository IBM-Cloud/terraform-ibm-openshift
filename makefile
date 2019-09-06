infrastructure:
	@[ "${rhn_username}" ] || ( echo ">> rhn_username is not set"; exit 1 )
	@[ "${rhn_password}" ] || ( echo ">> rhn_password is not set"; exit 1 )
	# Get the modules, create the infrastructure.
	terraform init && terraform get && terraform apply --target=ibm_compute_ssh_key.ssh_key_openshift --target=random_id.ose_name --target=module.network --target=module.publicsg --target=module.privatesg --target=module.bastion --target=module.masternode --target=module.appnode --target=module.infranode --auto-approve
	
	terraform init && terraform get && terraform apply --target=module.storagenode --target=module.inventory --auto-approve --parallelism=1 -var 'rhn_username=${rhn_username}' -var 'rhn_password=${rhn_password}'


rhnregister:	
	@[ "${rhn_username}" ] || ( echo ">> rhn_username is not set"; exit 1 )
	@[ "${rhn_password}" ] || ( echo ">> rhn_password is not set"; exit 1 )
	@[ "${pool_id}" ] || ( echo ">> pool_id is not set"; exit 1 )


	# Register the System with redhat
	terraform init && terraform get && terraform apply --target=module.rhn_register --auto-approve -var 'rhn_username=${rhn_username}' -var 'rhn_password=${rhn_password}' -var 'pool_id=${pool_id}'

openshift:	
	# Get the modules, for the pre install steps.
	terraform init && terraform get && terraform apply --target=module.openshift --auto-approve
	
destroy:
	# terraform init && terraform get && terraform destroy --target=module.loadbalancer --parallelism=1 --auto-approve 
	terraform init && terraform get && terraform destroy --auto-approve 

nodeprivate:
	terraform init && terraform get && terraform destroy --auto-approve --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule1 --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule2 --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule3 --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule4 --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule5 --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule6 --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule7 --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule8 

nodepublic:
	terraform init && terraform get && terraform apply --auto-approve --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule1 --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule2 --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule3 --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule4 --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule5 --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule6 --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule7 --target=module.publicsg.ibm_security_group_rule.openshift-node-ingress_rule8 
