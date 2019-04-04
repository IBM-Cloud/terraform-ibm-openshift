#--------------------------------#
#--------------------------------#

data "template_file" "master_block" {
  count = "${var.master_node_count}"
  template = "$${hostname} openshift_ip=$${ip} openshift_node_group_name='node-config-master'"
  vars {
   hostname = "${element(var.master_host, count.index)}.${var.domain}"
   ip = "${element(var.master_private_ip, count.index)}"
  }
}

data "template_file" "infra_block" {
  count = "${var.infra_node_count}"
  template = "$${hostname} openshift_ip=$${ip} openshift_node_group_name='node-config-infra'"
  vars {
   hostname = "${element(var.infra_host, count.index)}.${var.domain}"
   ip = "${element(var.infra_private_ip, count.index)}"
  }
}

data "template_file" "compute_block" {
  count = "${var.app_node_count}"
  template = "$${hostname} openshift_ip=$${ip} openshift_node_group_name='node-config-compute'"
  vars {
   hostname = "${element(var.app_host, count.index)}.${var.domain}"
   ip = "${element(var.app_private_ip, count.index)}"
  }
}

data "template_file" "gluster_block" {
  count = "${var.storage_node_count}"
  template = "$${hostname} glusterfs_ip=$${hostip} glusterfs_devices='[ \"/dev/dm-0\", \"/dev/dm-1\", \"/dev/dm-2\"]' openshift_node_group_name='node-config-compute'"
  vars {
   hostname = "${element(var.storage_host, count.index)}.${var.domain}"
   hostip = "${element(var.storage_private_ip, count.index)}"
  }
}


# Create the new Inventory file with master node info.
data "template_file" "ose_inventory_new" {
  template = "${var.storage_node_count == "0" ? "${file("${path.cwd}/templates/inventorywithoutgluster.cfg.tpl")}" : "${file("${path.cwd}/templates/inventory.cfg.tpl")}"}"
  vars {
    master_hostname = "${element(var.master_host, 0)}.${var.domain}"
    infra_hostname = "${element(var.infra_host, 0)}.${var.domain}"
    app_hostname = "${element(var.app_host, 0)}.${var.domain}"
    subdomain       = "apps.${element(var.infra_public_ip, 0)}.xip.io"
    master_block    = "${join("\n", data.template_file.master_block.*.rendered)}"
    compute_block   =  "${join("\n", data.template_file.compute_block.*.rendered)}"
    infra_block     =  "${join("\n", data.template_file.infra_block.*.rendered)}"
    gluster_block   =  "${join("\n", data.template_file.gluster_block.*.rendered)}"
  }
}

# Create a installer config file for openshift installation
resource "local_file" "ose_inventory_file" {
  content     =  "${data.template_file.ose_inventory_new.rendered}"
  filename    = "${path.cwd}/inventory_repo/inventory.cfg"
}


#--------------------------------#
#--------------------------------#

# Create host file
data "template_file" "master_host_file_template" {
  count = "${var.master_node_count}"
  template = "$${master_ip} $${master_hostname} $${master_hostname_domain} "
  vars {
    master_ip              = "${element(var.master_private_ip, count.index)}"
    master_hostname        = "${element(var.master_host, count.index)}"
    master_hostname_domain = "${element(var.master_host, count.index)}.${var.domain}"
  }
}

data "template_file" "master_public_host_file_template" {
  count = "${var.master_node_count}"
  template = "$${master_ip} $${master_hostname} $${master_hostname_domain} "
  vars {
    master_ip              = "${element(var.master_public_ip, count.index)}"
    master_hostname        = "${element(var.master_host, count.index)}"
    master_hostname_domain = "${element(var.master_host, count.index)}.${var.domain}"
  }
}

data "template_file" "app_host_file_template" {
  count = "${var.app_node_count}"
  template = "$${app_ip} $${app_hostname} $${app_hostname_domain} "
  vars {
    app_ip              = "${element(var.app_private_ip, count.index)}"
    app_hostname        = "${element(var.app_host, count.index)}"
    app_hostname_domain = "${element(var.app_host, count.index)}.${var.domain}"
  }
}

data "template_file" "infra_host_file_template" {
  count = "${var.infra_node_count}"
  template = "$${infra_ip} $${infra_hostname} $${infra_hostname_domain} "
  vars {
    infra_ip              = "${element(var.infra_private_ip, count.index)}"
    infra_hostname        = "${element(var.infra_host, count.index)}"
    infra_hostname_domain = "${element(var.infra_host, count.index)}.${var.domain}"
  }
}

data "template_file" "storage_host_file_template" {
  count = "${var.storage_node_count}"
  template = "$${storage_ip} $${storage_hostname} $${storage_hostname_domain} "
  vars {
    storage_ip              = "${element(var.storage_private_ip, count.index)}"
    storage_hostname        = "${element(var.storage_host, count.index)}"
    storage_hostname_domain = "${element(var.storage_host, count.index)}.${var.domain}"
  }
}

# Create a installer config file for openshift installation
resource "local_file" "host_file_render" {
  content     = "${join("\n", concat(data.template_file.master_host_file_template.*.rendered,data.template_file.infra_host_file_template.*.rendered,data.template_file.app_host_file_template.*.rendered,data.template_file.master_public_host_file_template.*.rendered,data.template_file.storage_host_file_template.*.rendered))}"
  filename    = "${path.cwd}/inventory_repo/hosts"
}


