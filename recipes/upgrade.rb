# Cookbook Name:: hanadb
# Recipe:: upgrade
# Upgrades an existing SAP Hana on the node.

hana_install_command = "./hdbupd --batch --sid=#{node['hana']['sid']} --password=#{node['hana']['password']} --system_user_password=#{node['hana']['syspassword']} --nostart=off --import_content=off"

server "run upgrade hana node" do
  exe "#{hana_install_command}"
end

# write a file, to the fs, which will state that the installation is finished, so if any worker installation runs, it can be sure
# that the installation of the master was finished
file "Create installation completion flag" do
  path "#{node['hana']['installpath']}/#{node['hana']['sid']}/install.finished"
  action :create
end