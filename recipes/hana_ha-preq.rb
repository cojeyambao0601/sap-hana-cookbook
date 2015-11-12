include_attributes "#{cookbook_name}::hana_ha"
include_recipe "zypper::default"


node[:hana][:ha][:repo_paths].each do |repo|
  zypper_repo repo do
    uri "#{node[:hana][:ha][:repo_baseurl]}/#{repo}"
    autorefresh true
    action :add
  end

end

node[:hana][:ha][:packadges].each do |pkg|
  package pkg
end


# node[:hana][:ha][:custom_repo_baseurl] = 'http://moo-repo.wdf.sap.corp:8080/static/monsoon/sap/hana-ha/'
# default[:hana][:ha][:custom_packadges]    = [ "SAPHanaSR-0.148-0.7.1.noarch.rpm", "SAPHanaSR-doc-0.148-0.7.1.noarch.rpm" ]

node[:hana][:ha][:custom_packadges].each do
  [pkg]
  remote_file '/tmp/#{pkg}' do
    source node[:hana][:ha][:custom_repo_baseurl] + '/' + pkg
    action :create
  end

  package pkg do
    source '/tmp/#{pkg}'
    action :install
  end
end


# find hana_ha_master1 & hana_ha_master2 if hana_ha_master1:dns_name == fqdn then ignore else add to hosts file
include_recipe "monsoon-search"

node[:hana][:ha][:tags].each do
  [member]
  search(:instances, "tags:#{member}") do |instance|
    # do something with the instance
    puts instance.inspect
  end
end

