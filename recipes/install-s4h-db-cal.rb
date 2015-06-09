# Cookbook Name:: hana
# Recipe:: install-s4h-db-cal
# Installs SAP Hana DB, for S4HANA, from a CAL image.

#ENV["TMPDIR"] = node[:sapinst][:sapprepare][:tmp_dir] if node[:sapinst][:sapprepare] && node[:sapinst][:sapprepare][:tmp_dir]
ENV["TMPDIR"] = "/hana"

#repo_dir = "#{node['s4h']['install']['repo']}/#{node['s4h']['product']}/#{node['s4h']['revision']}"

repodir = "static/monsoon/sap/s4hana/pc/1503"

directory "/hana/usr_sap" do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# ln -s /hana/usr_sap /usr/sap
link "/usr/sap" do
  action     :create
  mode '0755'
  link_type  :symbolic
  to "/hana/usr_sap"
end

node[:s4h][:media].each do |disk|
  sap_media disk do
    repo_path "/static/monsoon/sap/s4hana/pc/#{node[:s4h][:version]}"
    extractDir "#{node[:s4h][:media_dir]}/#{disk}"
  end
end

node[:s4h][:media].each do |disk|
  bash "restore files HANA DB-S4H - #{disk}" do
    user "root"
    code <<-EOF

  set -e
  cd /hana
  cat files/#{disk}/INST_FINAL_TECHCONF/db*.tgz-* | tar -zpxvf - -C /
  touch /hana/files/#{disk}/install.finished

    EOF
    not_if { ::File.exists?("/hana/files/#{disk}/install.finished")}
  end

end


#
# sap_media "DBDATA" do
#   extractDir "/hana/files"
#   repo_path "static/monsoon/sap/s4hana/pc/1503"
# end
#
# sap_media "DBEXE" do
#   extractDir "/hana/files-exe"
#   repo_path "static/monsoon/sap/s4hana/pc/1503"
# end
#
# sap_media "DBLOG" do
#   extractDir "/hana/files-log"
#   repo_path "static/monsoon/sap/s4hana/pc/1503"
# end



bash "restore files HANA DB - S4H - LOG" do
  user "root"
  code <<-EOF

  set -e
  cd /hana
  cat files/DBLOG/INST_FINAL_TECHCONF/dblog.tgz-* | tar -zpxvf - -C /
  touch /hana/log/install.finished

  EOF
  not_if { ::File.exists?("/hana/log/install.finished")}
end



bash "restore and recover HANA DB - S4H" do
  user "root"
  code <<-EOF

  set -e

  cd /hana
  cat files-log/INST_FINAL_TECHCONF/dblog.tgz-* | tar -zpxvf - -C /
  cat files/INST_FINAL_TECHCONF/dbdata.tgz-* | tar -zpxvf - -C /
  cat files-exe/INST_FINAL_TECHCONF/dbexe.tgz-* | tar -zpxvf - -C /

  chown -R 1000 data log shared usr_sap

  /hana/shared/H50/global/hdb/install/bin/hdbreg -b -password VA1MPwd_ -U 1000 --shell=/bin/sh -H hanavhost=mo-a193226cc -nostart

  su - h50adm  -c "hdbnsutil -convertTopology"

  su - h50adm  -c "HDB start"

  EOF
end
