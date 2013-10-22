default['hana']['installpath']    = "/usr/sap"
default['hana']['datapath']       = ""
default['hana']['logpath']        = ""
default['hana']['sid']            = "HNA"
default['hana']['instance']       = "00"
default['hana']['userid']         = "1099"
default['hana']['password']       = "Start1234"
default['hana']['syspassword']    = "Start1234"
default['hana']['checkhardware']  = "true"
default['hana']['checkstoignore'] = "check_platform,check_diskspace,check_min_mem"
default['hana']['clientsid']      = "true"
default['hana']['import_content'] = "off"
default['hana']['hostname']       = ""

# needed for distributed hana cluster
default['hana']['dist']['sharedvolume']         = ""
default['hana']['dist']['sharedmountoptions']   = ""
default['hana']['dist']['master-mode-required'] = "false"
default['hana']['dist']['waitcount']            = 5
default['hana']['dist']['waittime']             = 5
# needed for dist upgrade prcess on worker
default['hana']['dist']['2ndroot']              = "toor"
default['hana']['dist']['2ndrootclearpwd']      = "Toor1234"
default['hana']['dist']['2ndrootpwd']           = "$1$ytOMGuiO$KAPtio4Eh7JK0Rm4EAPzL/"

default['install']['tempdir']             = "/monsoon/tmp"
default['install']['files']['sapcar']     = "http://moo-repo.wdf.sap.corp:8080/static/monsoon/hana/newdb/SAPCAR"
default['install']['files']['saphostagent'] = "http://moo-repo.wdf.sap.corp:8080/static/monsoon/saphostagent/lnx_x64/7.2SP160/SAPHOSTAGENT.SAR"
default['install']['files']['hanadb']     = "http://moo-repo.wdf.sap.corp:8080/static/monsoon/hana/newdb/1.0.55/SAP_HANA_DATABASE100_55_Linux_on_x86_64.SAR"
default['install']['files']['hanaclient'] = "http://moo-repo.wdf.sap.corp:8080/static/monsoon/hana/newdb/1.0.55/SAP_HANA_CLIENT100_55_Linux_on_x86_64.SAR"
default['install']['files']['hanalifecyclemngr'] = "http://moo-repo.wdf.sap.corp:8080/static/monsoon/hana/newdb/SAPHANALM06P_2.SAR"
