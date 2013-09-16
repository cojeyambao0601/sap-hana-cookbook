# Cookbook Name:: hana
# Recipe:: install-lifecyclemngr
# Installs SAP Hana lifecycle manager on the node.

# verify HLM does not already exist
if !File.exists?("#{node['hana']['installpath']}/#{node['hana']['sid']}/HLM/hlmcli/hlmcli.sh")

	# HANA must exist before installing HLM
	include_recipe 'hana::install'
	
	# Install host agent 7.20 (patch level >= 153)
	directory "Create temporary directory" do
    path "#{node['install']['tempdir']}"
    action :create
    recursive true
  end

  execute "Get SAPCAR tool for Hana extracting hana package" do
    cwd "#{node['install']['tempdir']}"
    command "wget #{node['install']['files']['sapcar']} -O sapcar" #must not be named SAPCAR as it exists in archive
  end

  execute "Get SAP Host Agent package" do
    cwd "#{node['install']['tempdir']}"
    command "wget #{node['install']['files']['saphostagent']} -O SAP_HOST_AGENT.SAR"
  end

  execute "Extract & Install SAP Host Agent" do
    cwd "#{node['install']['tempdir']}"
    command "chmod +x sapcar && ./sapcar -xvf SAP_HOST_AGENT.SAR && ./saphostexec -install"
  end

  directory "Delete temporary directory" do
    path "#{node['install']['tempdir']}"
    recursive true
    action :delete
  end
	
	# Make SAR files available to installer as HLM stores a copy for use in remote installs
	directory "Create archive directory" do
    path "#{node['install']['tempdir']}/archives"
    action :create
    recursive true
  end

  execute "Get HANA lifecycle manager archive" do
    cwd "#{node['install']['tempdir']}/archives"
    command "wget #{node['install']['files']['hanalifecyclemngr']} -O SAPHANALM.SAR"
  end
	
  hana_install_command = "./hdbinst --batch --sid=#{node['hana']['sid']} --hlm_archive=#{node['install']['tempdir']}/archives/SAPHANALM.SAR"

  hdbcmd "run install of hana lifecycle manager" do
    exe hana_install_command
    bin_file_url node['install']['files']['hanalifecyclemngr']
  end

else
  log "HANA Lifecycle Manager appears to be installed, so skipping this step"
end