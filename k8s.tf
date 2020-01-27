/*
* Create K8s Master and worker nodes and etcd instances
*
*/

resource "aws_instance" "k8s-master" {
  ami           = "${data.aws_ami.distro.id}"
  instance_type = "${var.aws_kube_master_size}"

  count = "${var.aws_kube_master_num}"

  availability_zone = "${element(slice(data.aws_availability_zones.available.names, 0, 2), count.index)}"
  subnet_id         = "${element(module.aws-vpc.aws_subnet_ids_private, count.index)}"

  vpc_security_group_ids = "${module.aws-vpc.aws_security_group}"

  iam_instance_profile = "${module.aws-iam.kube-master-profile}"
  key_name             = "${var.AWS_SSH_KEY_NAME}"

  tags = "${merge(var.default_tags, map(
    "Name", "kubernetes-${var.aws_cluster_name}-master${count.index}",
    "kubernetes.io/cluster/${var.aws_cluster_name}", "member",
    "Role", "master"
  ))}"
}

resource "aws_instance" "k8s-etcd" {
  ami           = "${data.aws_ami.distro.id}"
  instance_type = "${var.aws_etcd_size}"

  count = "${var.aws_etcd_num}"

  availability_zone = "${element(slice(data.aws_availability_zones.available.names, 0, 2), count.index)}"
  subnet_id         = "${element(module.aws-vpc.aws_subnet_ids_private, count.index)}"

  vpc_security_group_ids = "${module.aws-vpc.aws_security_group}"

  key_name = "${var.AWS_SSH_KEY_NAME}"

  tags = "${merge(var.default_tags, map(
    "Name", "kubernetes-${var.aws_cluster_name}-etcd${count.index}",
    "kubernetes.io/cluster/${var.aws_cluster_name}", "member",
    "Role", "etcd"
  ))}"
}

resource "aws_instance" "k8s-worker" {
  ami           = "${data.aws_ami.distro.id}"
  instance_type = "${var.aws_kube_worker_size}"

  count = "${var.aws_kube_worker_num}"

  availability_zone = "${element(slice(data.aws_availability_zones.available.names, 0, 2), count.index)}"
  subnet_id         = "${element(module.aws-vpc.aws_subnet_ids_private, count.index)}"

  vpc_security_group_ids = "${module.aws-vpc.aws_security_group}"

  iam_instance_profile = "${module.aws-iam.kube-worker-profile}"
  key_name             = "${var.AWS_SSH_KEY_NAME}"

  tags = "${merge(var.default_tags, map(
    "Name", "kubernetes-${var.aws_cluster_name}-worker${count.index}",
    "kubernetes.io/cluster/${var.aws_cluster_name}", "member",
    "Role", "worker"
  ))}"
}

/*
* Create Kubespray Inventory File
*
*/
data "template_file" "inventory" {
  template = "${file("${path.module}/templates/inventory.tpl")}"

  vars = {
    public_ip_address_bastion = "${join("\n", formatlist("bastion ansible_host=%s", aws_instance.bastion-server.*.public_ip))}"
    connection_strings_master = "${join("\n", formatlist("%s ansible_host=%s", aws_instance.k8s-master.*.tags.Name, aws_instance.k8s-master.*.private_ip))}"
    connection_strings_node   = "${join("\n", formatlist("%s ansible_host=%s", aws_instance.k8s-worker.*.tags.Name, aws_instance.k8s-worker.*.private_ip))}"
    connection_strings_etcd   = "${join("\n", formatlist("%s ansible_host=%s", aws_instance.k8s-etcd.*.tags.Name, aws_instance.k8s-etcd.*.private_ip))}"
    list_master               = "${join("\n", aws_instance.k8s-master.*.tags.Name)}"
    list_node                 = "${join("\n", aws_instance.k8s-worker.*.tags.Name)}"
    list_etcd                 = "${join("\n", aws_instance.k8s-etcd.*.tags.Name)}"
    elb_api_fqdn              = "apiserver_loadbalancer_domain_name=\"${module.aws-elb.aws_elb_api_fqdn}\""
  }
}

resource "null_resource" "inventories" {
  provisioner "local-exec" {
    command = "echo '${data.template_file.inventory.rendered}' > ${var.inventory_file}"
  }

  triggers = {
    template = "${data.template_file.inventory.rendered}"
  }
}