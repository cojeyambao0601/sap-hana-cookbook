if !File.exists?("#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec/sapsrv.pse")

	directory "#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec" do
		recursive true
		user "#{node['hana']['sid']}adm".downcase
		group "sapsys"
		action :create
	end

  # Install cryptolib
  directory "Create temporary directory" do
    path node['install']['tempdir']
    action :create
    recursive true
  end

  #Get SAPCAR tool for Hana extracting hana package
  remote_file "#{node['install']['tempdir']}/sapcar" do
    source node['install']['files']['sapcar']
  end

  #Get SAP Cryptolib package
  remote_file "#{node['install']['tempdir']}/SAPCRYPTO.SAR" do
    source node['install']['files']['sapcryptolib']
  end

  execute "Extract & Install SAP Host Agent" do
    cwd node['install']['tempdir']
    command "chmod +x sapcar && ./sapcar -xvf SAPCRYPTO.SAR"
  end
	
  bash "copy cryptolib" do
    user "#{node['hana']['sid']}adm".downcase
    group "sapsys"
    cwd "#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/trace"
    code <<-EOH
    cp #{node['install']['tempdir']}/linux-x86_64-glibc2.3/sapgenpse #{node['hana']['installpath']}/#{node['hana']['sid']}/global/security/lib/
    cp #{node['install']['tempdir']}/linux-x86_64-glibc2.3/libsapcrypto.so #{node['hana']['installpath']}/#{node['hana']['sid']}/global/security/lib/
    EOH
  end

  directory "Delete temporary directory" do
    path node['install']['tempdir']
    recursive true
    action :delete
  end

  csh "generate pse" do
    user "#{node['hana']['sid']}adm".downcase
    group "sapsys"
    cwd "#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec"
    code <<-EOH
      setenv LD_LIBRARY_PATH #{node['hana']['installpath']}/#{node['hana']['sid']}/global/security/lib
      #{node['hana']['installpath']}/#{node['hana']['sid']}/global/security/lib/sapgenpse gen_pse -p #{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec/sapsrv.pse -x '' -r #{node['hostname']}-#{node['hana']['sid']}.req "CN=#{node['monsoon']['instances']["#{node['monsoon']['instance']['identity']}"]['dns_name']}, OU=#{node['hana']['sid']}, O=SAP-AG, C=DE"
    EOH
    not_if {File.exists?("#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec/sapsrv.pse")}
  end

  Chef::Log.info "################# Create sapwebdisp.pfl for ssl definition ###################"
  template "#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/wdisp/sapwebdisp.pfl" do
    source "wdisp/sapwebdisp.pfl.erb"
    owner "#{node['hana']['sid']}adm".downcase
      variables(
        :instance => node['hana']['instance'],
        :sid => node['hana']['sid'],
        :xs_http_port => node['hana']['xs_http_port'],
        :xs_https_port => node['hana']['xs_https_port'],
        :hostname => node['hostname'],
        :installpath => node['hana']['installpath']
      )
  end

  bash "activate external icmbnd" do
    cwd "#{node['hana']['installpath']}/#{node['hana']['sid']}/exe/linuxx86_64/hdb"
    code <<-EOH
      mv icmbnd.new icmbnd
      chown root:sapsys icmbnd
      chmod 4750 icmbnd
    EOH
  end
  

  bash "restart webdispatcher and xsengine" do
    user "#{node['hana']['sid']}adm".downcase
    group "sapsys"
    cwd "#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/trace"
        code <<-EOH
	kill -9 `pidof hdbxsengine`
	kill -9 `pidof sapwebdisp_hdb`
	sleep 30
	EOH
  end
    
else
  Chef::Log.info "################# pse file already exists, doing nothing ###################"
  log "################# Seems sapsrv.pse keystore file already exists, for new cert import delete #{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec/sapsrv.pse first ###################"

end