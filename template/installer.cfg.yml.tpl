ansible_callback_facts_yaml: /root/.config/openshift/.ansible/callback_facts.yaml
ansible_inventory_path: /root/.config/openshift/hosts
ansible_log_path: /tmp/ansible.log
deployment:
  ansible_ssh_user: root
  hosts:
  - connect_to: ${master_private_ip}
    hostname: ${master_hostname}
    ip: ${master_private_ip}
    public_hostname: ${master_hostname}
    public_ip: ${master_public_ip}
    roles:
    - master
    - etcd
    - storage
  - connect_to: ${app_private_ip}
    hostname: ${app_hostname}
    ip: ${app_private_ip}
    public_hostname: ${app_hostname}
    public_ip: ${app_public_ip}
    roles:
    - node
  - connect_to: ${infra_private_ip}
    hostname: ${infra_hostname}
    ip: ${infra_private_ip}
    node_labels: '{''region'': ''infra''}'
    public_hostname: ${infra_hostname}
    public_ip: ${infra_public_ip}
    roles:
    - node
  master_routingconfig_subdomain: ''
  openshift_disable_check: docker_image_availability,docker_storage,memory_availability,package_availability,package_version
  openshift_master_identity_providers: [{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]
  openshift_master_cluster_hostname: None
  openshift_master_cluster_public_hostname: None
  proxy_exclude_hosts: ''
  proxy_http: ''
  proxy_https: ''
  roles:
    etcd: {}
    master: {}
    node: {}
    storage: {}
variant: openshift-enterprise
variant_version: '3.6'
version: v2