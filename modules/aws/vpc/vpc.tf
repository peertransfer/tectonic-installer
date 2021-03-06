data "aws_availability_zones" "azs" {}

resource "aws_vpc" "new_vpc" {
  count                = "${var.external_vpc_id == "" ? 1 : 0}"
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = "${merge(map(
      "Name", "${var.cluster_name}",
      "KubernetesCluster", "${var.cluster_name}"
    ), var.extra_tags)}"
}

data "aws_vpc" "cluster_vpc" {
  # The join() hack is required because currently the ternary operator
  # evaluates the expressions on both branches of the condition before
  # returning a value. When providing and external VPC, the template VPC
  # resource gets a count of zero which triggers an evaluation error.
  #
  # This is tracked upstream: https://github.com/hashicorp/hil/issues/50
  #
  id = "${var.external_vpc_id == "" ? join(" ", aws_vpc.new_vpc.*.id) : var.external_vpc_id }"
}
