# Simple provider to encapsulate the actions of HLM

action :add_afl do
	command_string = "add_afl --afl_path #{@new_resource.archive_path}"
	
	hlmcli(command_string)
end

action :add_lca do
	command_string = "add_lca --lca_path #{@new_resource.archive_path}"
	
	hlmcli(command_string)
end

action :add_sda do
	command_string = "add_sda --sda_path #{@new_resource.archive_path}"
	
	hlmcli(command_string)
end

action :update_hlm do
	if @new_resource.update_source.eql? "marketplace" 
		command_string = "update_hana_lifecycle_manager --confirm_dialog true --update_source #{@new_resource.update_source} --use_proxy #{@new_resource.use_proxy} --proxy_host #{@new_resource.proxy_host}  --proxy_port #{@new_resource.proxy_port} --smp_user #{@new_resource.smp_user} --smp_pwd #{@new_resource.smp_pass}"
	else
		command_string = "update_hana_lifecycle_manager --confirm_dialog true --update_source #{@new_resource.update_source} --hlm_file_path #{@new_resource.archive_path}"
	end
	
	hlmcli(command_string)
end

action :apply_sp do
	command_string = "apply_single_support_package --confirm_dialog true  --update_source #{@new_resource.update_source} --instance_Nr #{node['hana']['instance']} --db_user SYSTEM --db_pwd #{node['hana']['syspassword']} "

	if @new_resource.update_source.eql? "marketplace" 
		 command_string = command_string + "--use_proxy #{@new_resource.use_proxy} --proxy_host #{@new_resource.proxy_host}  --proxy_port #{@new_resource.proxy_port} --smp_user #{@new_resource.smp_user} --smp_pwd #{@new_resource.smp_pass}"
	else
		command_string = command_string + "--inbox_directory #{@new_resource.archive_path}"
	end
	
	hlmcli(command_string)
end

action :deploy_content do
	command_string = "deploy_hana_content --confirm_dialog true --instance_Nr #{node['hana']['instance']} --db_user SYSTEM --db_pwd #{node['hana']['syspassword']} --content_file_path #{@new_resource.archive_path} --content_update_source remote"
	
	hlmcli(command_string)
end

action :add_host do
	command_string = "add_host --addhost_hostname #{@new_resource.hostname} --addhost_sapadm_pwd #{@new_resource.sapadm_pass} --addhost_role #{@new_resource.role} --addhost_memory #{node['hana']['sid']}=#{@new_resource.target_memory}"
	
	hlmcli(command_string)
end

action :add_system do
	#build default log and data path if none is provided
	if @new_resource.target_datapath.nil?
		datapath = "#{node['hana']['installpath']}/#{@new_resource.target_sid}/global/hdb/data"
	else
		datapath = @new_resource.target_datapath
	end
	if @new_resource.target_logpath.nil?
		logpath = "#{node['hana']['installpath']}/#{@new_resource.target_sid}/global/hdb/log"
	else
		logpath = @new_resource.target_logpath
	end
	
	#create data and log dirs if they dont exist
	directory datapath do
    mode "664"
    owner #{node['hana']['sid'].downcase}adm
    group "sapsys"
    action :create
    recursive true
		not_if ::File.directory? datapath
  end
	directory logpath do
    mode "664"
    owner #{node['hana']['sid'].downcase}adm
    group "sapsys"
    action :create
    recursive true
		not_if ::File.directory? logpath
  end

	command_string = "add_hana_system --dvdpath #{@new_resource.archive_path} --new_system_sid #{@new_resource.target_sid} --sapmntpath #{node['hana']['installpath']} --instance_number #{@new_resource.target_instance} --memory_configuration #{@new_resource.target_memory} --datapath " + datapath + " --logpath " + logpath + " --master_password #{@new_resource.target_pass}"
	
	hlmcli(command_string)
end

action :remove_host do
	command_string = "remove_host --removehost_hostname #{@new_resource.hostname}"
	
	hlmcli(command_string)
end

# basics of the hlmcli command
def hlmcli(operation)
	# before doing anything make sure the cli exists
	if !::File.exist?("#{node['hana']['installpath']}/#{node['hana']['sid']}/HLM/hlmcli/hlmcli.sh")
		raise "HANA Lifecycle Manager is not installed."
	end
	
	execute "Execute HLM command line" do
		cwd "#{node['hana']['installpath']}/#{node['hana']['sid']}/HLM/hlmcli"
		user #{node['hana']['sid'].downcase}adm
		command "./hlmcli.sh --sid #{node['hana']['sid']} --sidadm_pwd #{node['hana']['password']} #{operation}"
	end
end