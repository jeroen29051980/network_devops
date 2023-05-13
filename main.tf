variable "tenancy_ocid" {
  type        = string
  description = "The tenancy OCID"
  default     = "ocid1.tenancy.oc1..aaaaaaaaqh23tupwfbofw6ueekpbjqvstsjs2guugaixvfbyszi7m2jifaeq"
}

variable "user_ocid" {
  type        = string
  description = "The user OCID"
  default     = "ocid1.user.oc1..aaaaaaaanrqlbsqu36eaqldcpfp5guuo2wbqersdeqsfkkxt7yc73kof2d3a"
}

variable "vm_shape" {
  type        = string
  description = "The shape of the VM"
  default     = "VM.Standard.E2.1"
}

locals {
  instances = {
    "0" = "MainVM"
    "1" = "DataVM"
    "2" = "BackupVM"
  }
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = "52:5d:08:ce:82:b4:25:2b:27:02:6d:e7:db:4f:7e:7e"
  private_key_path = "/home/jeroen/DEVOPS_PROJ/files/KEYS/OCI.pem"
  region           = "eu-amsterdam-1"
}


terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 4.0.0"
    }  echo "Geef de user-ID (OCI_ID):"
  read OCI_user_input
  export OCI_user_input
  echo -e "\n Geef de tenant-ID (OCI_ID):"
  read OCI_tenant_input
  export OCI_tenant_input
  echo -e "\n Geef de fingerprint-ID:"
  read OCI_fingerprint_input
  export OCI_fingerprint_input
  }
}

data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = var.tenancy_ocid
}

resource "oci_core_vcn" "vcn" {
  #Required
  compartment_id = var.tenancy_ocid
  cidr_block     = "10.0.0.0/16"
}


# allow inbound port TCP 22 + TCP 80 + TCP 443 and EVERYTHING outbound
resource "oci_core_security_list" "TerraformedVM" {
  #Required
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "TerraformedVM"
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6" # TCP
    tcp_options {
      max = 80
      min = 80
    }
  }

  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6" # TCP
    tcp_options {
      max = 22
      min = 22
    }
  }

  egress_security_rules {
    destination  = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6" # TCP
    tcp_options {
      max = 8080
      min = 8080
    }
  }
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6" # TCP
    tcp_options {
      max = 443
      min = 443
    }
  }

  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6" # TCP
    tcp_options {
      max = 445
      min = 445
    }
  }
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6" # TCP
    tcp_options {
      max = 139
      min = 139
    }
  }
  egress_security_rules {
    destination  = "0.0.0.0/0"
    protocol    = "all"
  }
}

resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.vcn.id
}

resource "oci_core_route_table" "internet" {
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.vcn.id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.internet_gateway.id
  }
}


resource "oci_core_subnet" "subnet" {
  #Required
  compartment_id      = var.tenancy_ocid
  availability_domain = data.oci_identity_availability_domains.availability_domains.availability_domains.0.name
  cidr_block          = "10.0.1.0/24"
  vcn_id              = oci_core_vcn.vcn.id
  route_table_id      = oci_core_route_table.internet.id
  security_list_ids = [
    oci_core_security_list.TerraformedVM.id
  ]
}

data "oci_core_images" "ubuntu" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "22.04"
  shape                    = var.vm_shape
}

resource "oci_core_instance" "TerraformedVM" {
  for_each = local.instances

  availability_domain = data.oci_identity_availability_domains.availability_domains.availability_domains.0.name
  compartment_id      = var.tenancy_ocid
  display_name        = each.value
  shape               = var.vm_shape

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu.images.0.id
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.subnet.id
  }

  # Add SSH key
  extended_metadata = {
    ssh_authorized_keys = file("/tmp/sshkey.pub")
  }
}

resource "time_sleep" "wait" {
  depends_on = [oci_core_instance.TerraformedVM]
  create_duration   = "60s"
}

resource "null_resource" "generate-inventory" {
  for_each = local.instances
  provisioner "local-exec" {
    command = <<-EOT
      echo [New-Servers] >> inventory
      echo ${oci_core_instance.TerraformedVM[each.key].display_name} ansible_host=${oci_core_instance.TerraformedVM[each.key].public_ip} ansible_user=opc ansible_ssh_private_key_file=/tmp/sshkey >> inventory
    EOT
  }
  depends_on = [time_sleep.wait]
}
resource "null_resource" "execute-playbook" {

  provisioner "local-exec" {
    command = "ansible-playbook -i inventory install.yaml"
  }
  depends_on = [null_resource.generate-inventory]
}
