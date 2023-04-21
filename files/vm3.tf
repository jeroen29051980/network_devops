variable "tenancy_ocid" {
  type        = string
  description = "The tenancy OCID"
  default     = "$OCI_tentant_input"
}

variable "user_ocid" {
  type        = string
  description = "The user OCID"
  default     = "$OCI_tentant_input"
}

variable "vm_shape" {
  type        = string
  description = "The shape of the VM"
  default     = "VM.Standard.E2.1.Micro"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = "$OCI_fingerprint_input"
  private_key_path = "/home/$USER/DEVOPS_PROJ/files/KEYS/oci.pem"
  region           = "eu-amsterdam-1"
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
resource "oci_core_security_list" "BACKUP_VM" {
  #Required
  compartment_id = var.tenancy_ocid
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "BACKUP_VM"
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
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6" # TCP
    tcp_options {
      max = 443
      min = 443
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
    oci_core_security_list.BACKUP_VM.id
  ]
}

data "oci_core_images" "ubuntu" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "Canonical"
  operating_system_version = "Ubuntu 22.04"
  shape                    = var.vm_shape
}

resource "oci_core_instance" "BACKUP_VM" {
  availability_domain = data.oci_identity_availability_domains.availability_domains.availability_domains.0.name
  compartment_id      = var.tenancy_ocid
  display_name        = "BACKUP_VM"
  shape               = var.vm_shape

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.centos.images.0.id
  }

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.subnet.id
  }

  # Add SSH key
  extended_metadata = {
    ssh_authorized_keys = file("~/.ssh/id_rsa.pub")
  }
}