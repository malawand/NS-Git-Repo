terraform {
  required_version = ">=1.1.9"
  required_providers {
    aci = {
      source = "ciscodevnet/aci"
      version = ">=2.2.1"
    }
  }
}

provider "aci" {
  username = var.username	
  password = var.password
  url = var.apic 
  insecure = true
}

resource "aci_tenant" "jamestam_tf_tn" {
  name         = "jamestam_tf_tn"
  description  = "Prod tenant!!!!"  #Update to change ACI tenant description
}

#Uncomment below for more ACI tenant policies

resource "aci_application_profile" "app1" {
  tenant_dn = aci_tenant.jamestam_tf_tn.id
  #tenant_dn = "uni/tn-jamestam_tf_tn"
  name      = "app1"
}

resource "aci_application_epg" "epg1" {
  application_profile_dn = aci_application_profile.app1.id
  name                   = "epg1"
  relation_fv_rs_bd      = aci_bridge_domain.bd1.id
  relation_fv_rs_prov    = [aci_contract.contract1.id]
}

resource "aci_application_epg" "epg2" {
  application_profile_dn = aci_application_profile.app1.id
  name                   = "epg2"
  relation_fv_rs_bd      = aci_bridge_domain.bd2.id
  relation_fv_rs_cons    = [aci_contract.contract1.id]
}

resource "aci_bridge_domain" "bd1" {
  tenant_dn          = aci_tenant.jamestam_tf_tn.id
  relation_fv_rs_ctx = aci_vrf.vrf2.id
  name               = "bd1"
}

resource "aci_subnet" "bd1_subnet" {
  parent_dn        = aci_bridge_domain.bd1.id
  ip               = "192.168.0.1/24"
}

resource "aci_bridge_domain" "bd2" {
  tenant_dn          = aci_tenant.jamestam_tf_tn.id
  relation_fv_rs_ctx = aci_vrf.vrf2.id
  name               = "bd2"
}

resource "aci_subnet" "bd2_subnet" {
  parent_dn        = aci_bridge_domain.bd2.id
  ip               = "172.16.0.1/24"
}

resource "aci_vrf" "vrf1" {
  tenant_dn = aci_tenant.jamestam_tf_tn.id
  name      = "vrf1"
}

resource "aci_vrf" "vrf2" {
  tenant_dn = aci_tenant.jamestam_tf_tn.id
  name      = "vrf2"
}

resource "aci_contract" "contract1" {
  tenant_dn = "${aci_tenant.jamestam_tf_tn.id}"
  name      = "contract1"
}

resource "aci_contract_subject" "subject_tf" {
  contract_dn                  = "${aci_contract.contract1.id}"
  name                         = "subject1"
  relation_vz_rs_subj_filt_att = [
     "${aci_filter.allow_http.id}",
     "${aci_filter.allow_icmp.id}",
  ]
}

resource "aci_filter" "allow_http" {
  tenant_dn = "${aci_tenant.jamestam_tf_tn.id}"
  name      = "allow_http"
}
resource "aci_filter" "allow_icmp" {
  tenant_dn = "${aci_tenant.jamestam_tf_tn.id}"
  name      = "allow_icmp"
}

resource "aci_filter_entry" "http" {
  name        = "http"
  filter_dn   = "${aci_filter.allow_http.id}"
  ether_t     = "ip"
  prot        = "tcp"
  d_from_port = "http"
  d_to_port   = "http"
  stateful    = "yes"
}

resource "aci_filter_entry" "icmp" {
  name        = "icmp"
  filter_dn   = "${aci_filter.allow_icmp.id}"
  ether_t     = "ip"
  prot        = "icmp"
  stateful    = "yes"
}
