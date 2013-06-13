# Cookbook Name:: hanadb
# Recipe:: upgrade
# Upgrades an existing SAP Hana on the node.

hana_install_command = "./hdbupd --batch --sid=#{node['hana']['sid']} --password=#{node['hana']['password']} --system_user_password=#{node['hana']['syspassword']} --nostart=off --import_content=off"

server "run upgrade hana node" do
  exe "#{hana_install_command}"
end