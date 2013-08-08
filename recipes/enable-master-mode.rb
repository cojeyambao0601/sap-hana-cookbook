# Cookbook Name:: hana
# Recipe:: enable-master-mode
# enable the special master mode for hana distributed installs required in newer versions
# set the attribute hana-dist-master-mode-required to true in case the worker install gives
# you the following error:
# Parameter 'listeninterface' is set to '.local'.
#      Please reconfigure your master node:
#      Perform 'hdbnsutil -reconfig --hostnameResolution=global' as sidadm on master node.

# tell that we run this script now
log "Running #{File.basename(__FILE__)} recipe:"

adminuser = node['hana']['sid'].downcase + "adm"

bash "enable the special master mode for hana distributed installs" do only_if { node['hana']['dist']['master-mode-required'] }
code <<-EOH
su --login #{adminuser} -c "hdbnsutil -reconfig --hostnameResolution=global"
EOH
end
