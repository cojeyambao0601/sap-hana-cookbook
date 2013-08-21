# Cookbook Name:: hana
# Recipe:: install-lifecyclemngr
# Installs SAP Hana lifecycle manager on the node.

# verify HLM does not already exist
if !File.exists?("#{node['hana']['installpath']}/#{node['hana']['sid']}/HLM/hlmcli/hlmcli.sh")

	# HANA must exist before installing HLM
	include_recipe 'hana::install'
	
	# Make SAR files available to installer as HLM stores a copy for use in remote installs
	directory "Create archive directory" do
    path "#{node['install']['tempdir']}/archives"
    action :create
    recursive true
  end

  execute "Get SAPHOSTAGENT archive" do
    cwd "#{node['install']['tempdir']}/archives"
    command "wget #{node['install']['files']['saphostagent']} -O SAPHOSTAGENT.SAR"
  end

  execute "Get Hana binary package" do
    cwd "#{node['install']['tempdir']}/archives"
    command "wget #{node['install']['files']['hanalifecyclemngr']} -O SAPHANALM.SAR"
  end
	
  hana_install_command = "./hdbinst --batch --sid=#{node['hana']['sid']} --hlm_archive=#{node['install']['tempdir']}/archives/SAPHANALM.SAR --host_agent_package=#{node['install']['tempdir']}/archives/SAPHOSTAGENT.SAR"

  hdbcmd "run install of hana lifecycle manager" do
    exe "#{hana_install_command}"
    bin_dir "SAP_HANA_LM"
    bin_file_url "#{node['install']['files']['hanalifecyclemngr']}"
  end

else
  log "HANA Lifecycle Manager appears to be installed, so skipping this step"
end