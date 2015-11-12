
default[:hana][:ha][:repo_baseurl]        = 'http://moo-repo.wdf.sap.corp:8080/mrepo/suse/11/'
default[:hana][:ha][:repo_paths]          = [ "SLE11-HAE-SP3-Pool/sle-11-x86_64/SLE11-HAE-SP3-Pool", "SLE11-HAE-SP3-Updates/sle-11-x86_64/SLE11-HAE-SP3-Updates"]
default[:hana][:ha][:packadges]           = [ "corosync","hawk","sle-hae-release","pssh","cmirrord","sleha-bootstrap","conntrack-tools","crmsh","python-dateutil","ldirectord","ocfs2-tools","csync2","openais","ctdb","drbd","yast2-cluster","python-pssh","yast2-drbd","yast2-iplb","pacemaker","pacemaker-mgmt","pacemaker-mgmt-client","release-notes-hae","resource-agents","lvm2-clvm" ]


default[:hana][:ha][:custom_repo_baseurl] = 'http://moo-repo.wdf.sap.corp:8080/static/monsoon/sap/hana-ha/'
default[:hana][:ha][:custom_packadges]    = [ "SAPHanaSR-0.148-0.7.1.noarch.rpm", "SAPHanaSR-doc-0.148-0.7.1.noarch.rpm" ]
default[:hana][:ha][:tags] = ["hana_ha_master1", "hana_ha_master2"]