
include_attributes "#{cookbook_name}::hana_ha"
include_recipe "zypper::default"


node[:hana][:ha][:repo_paths].each do |repo|
  zypper_repo repo do
    uri "#{node[:hana][:ha][:repo_baseurl]}/#{repo}"
    autorefresh true
    action :add
  end

end

