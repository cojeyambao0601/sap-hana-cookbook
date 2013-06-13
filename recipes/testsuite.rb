remote_directory "/root/features/#{cookbook_name}/" do
  source "testsuite/features"
  owner "root"
  group "root"
  mode "0755"
end

gem_package "rspec" do
  action :install
end
