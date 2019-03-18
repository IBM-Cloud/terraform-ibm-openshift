	#!/bin/sh
	# Install openshift
	scp -o StrictHostKeyChecking=no ./inventory_repo/inventory.cfg root@$1:/root/
	ssh -o TCPKeepAlive=yes -o ServerAliveInterval=50 -o StrictHostKeyChecking=no root@$1 'ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/prerequisites.yml -e ansible_user=root'
	ssh -o TCPKeepAlive=yes -o ServerAliveInterval=50 -o StrictHostKeyChecking=no -A root@$1 'ansible-playbook -i /root/inventory.cfg /usr/share/ansible/openshift-ansible/playbooks/deploy_cluster.yml -e ansible_user=root'
