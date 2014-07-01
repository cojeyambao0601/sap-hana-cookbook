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
default['hana']['import_content'] = "on"
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

# xs attributes
default['hana']['import_content'] = "on"
default['hana']['xs_http_port']   = "80" + node['hana']['instance']
default['hana']['xs_https_port']  = "443"

default['install']['tempdir']             		= "/monsoon/tmp"

default['install']['repo']       				= "http://moo-repo.wdf.sap.corp:8080/static/monsoon/hana/newdb"
default['install']['productiondevice1']  	= "derotvi0066.wdf.sap.corp:/derotvi0066a_ld9252/q_files"
default['install']['productiondevice2']  	= "nsvf1735.wdf.sap.corp:/vol/nsvf1735a_newdb/q_newdb"
default['install']['productionmountpoint1']  	      = "/sapmnt/production/makeresults/newdb_archive"
default['install']['productionmountpoint2']  	      = "/sapmnt/production/newdb"
default['hana']['revision'] 					= '67'

# donwload sapcar executable ...
default['install']['files']['sapcar']     			= "http://moo-repo.wdf.sap.corp:8080/static/monsoon/hana/newdb/SAPCAR"
default['install']['files']['hostagent'] 			= "http://moo-repo.wdf.sap.corp:8080/static/monsoon/saphostagent/lnx_x64/7.2SP160/SAPHOSTAGENT.SAR"
default['install']['files']['sapcryptolib']		= "http://moo-repo.wdf.sap.corp:8080/static/monsoon/sap/sapcryptolib/SAPCRYPTOLIB_34-10010845.SAR"

# construct url from install repo
default['install']['files']['hanadb'] 				= node['install']['repo'] + "/1.0." + node['hana']['revision'] + "/SAP_HANA_DATABASE100_" + node['hana']['revision'] + "_Linux_on_x86_64.SAR"
default['install']['files']['hanaclient'] 			= node['install']['repo'] + "/1.0." + node['hana']['revision'] + "/SAP_HANA_CLIENT100_" + node['hana']['revision'] + "_Linux_on_x86_64.SAR"
default['install']['files']['lifecyclemngr'] 		= node['install']['repo'] + "/SAPHANALM_" + node['hana']['revision'][0] + ".SAR"
default['install']['files']['hanalifecyclemngr'] 	= node['install']['files']['lifecyclemngr']
default['install']['files']['saphostagent'] 		= node['install']['files']['hostagent']
default['install']['files']['afl'] 			= node['install']['repo'] + "/1.0." + node['hana']['revision'] + "/SAP_HANA_AFL100_" + node['hana']['revision'] + "_1" + "_Linux_on_x86_64.SAR"
default['install']['files']['afl-sal'] 			= "http://moo-repo.wdf.sap.corp:8080/static/monsoon/hana/bobj/lumira/SAP_SAL_AFL_PATCH_1_FOR_SAP_HANA.SAR"
