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
			#{node['hana']['installpath']}/#{node['hana']['sid']}/global/security/lib/sapgenpse gen_pse -p #{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/sec/sapsrv.pse -x '' "CN=#{node['hostname']}"
			EOH
	end

	bash "update wdisp profile" do
		user "#{node['hana']['sid']}adm".downcase
		group "sapsys"
		cwd "#{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/trace"
		code <<-EOH
			echo 'DIR_SECURITY_LIB = #{node['hana']['installpath']}/#{node['hana']['sid']}/SYS/global/security/lib' >> #{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/wdisp/sapwebdisp.pfl
			echo 'wdisp/ssl_encrypt = 0' >> #{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/wdisp/sapwebdisp.pfl
			echo 'ssl/ssl_lib=#{node['hana']['installpath']}/#{node['hana']['sid']}/global/security/lib/libsapcrypto.so' >> #{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/wdisp/sapwebdisp.pfl
			echo 'ssl/server_pse = sapsrv.pse' >> #{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/wdisp/sapwebdisp.pfl
			echo 'icm/HTTPS/verify_client=1' >> #{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/wdisp/sapwebdisp.pfl
			echo 'icm/HTTPS/forward_ccert_as_header=true' >> #{node['hana']['installpath']}/#{node['hana']['sid']}/HDB#{node['hana']['instance']}/#{node['hostname']}/wdisp/sapwebdisp.pfl
			kill -9 `pidof hdbxsengine`
			kill -9 `pidof sapwebdisp_hdb`
			sleep 15
			EOH
	end

end