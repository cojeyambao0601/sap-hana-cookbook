define :hdbcmd, :exe => "", :bin_dir => "", :bin_file_url => "" do

  # check for platform and install libraries
  include_recipe "hana::install-libs"

  directory "Create temporary directory" do
    path "#{node['install']['tempdir']}"
    action :create
    recursive true
  end

  execute "Get SAPCAR tool for Hana extracting hana package" do
    cwd "#{node['install']['tempdir']}"
    command "wget #{node['install']['files']['sapcar']}"
  end

  if params[:bin_file_url].start_with?("http")
    execute "Get Hana binary package" do
      cwd "#{node['install']['tempdir']}"
      command "wget --progress=dot:giga #{params[:bin_file_url]} -O SAP_HANA_PACKAGE.SAR"
    end
  else
    directory "#{node['install']['productionmountpoint1']}" do
      action :create
      recursive true 
    end
    mount "#{node['install']['productionmountpoint1']}" do
      device "#{node['install']['productiondevice1']}"
      fstype "nfs"
      action :mount
    end
    directory "#{node['install']['productionmountpoint2']}" do
      action :create
      recursive true 
    end
    mount "#{node['install']['productionmountpoint2']}" do
      device "#{node['install']['productiondevice2']}"
      fstype "nfs"
      action :mount
    end
    execute "Get Hana binary package" do
      cwd "#{node['install']['tempdir']}"
      command "cp #{params[:bin_file_url]} SAP_HANA_PACKAGE.SAR"
    end
  end
  #remote_file would fit both variants, but seems to be very slow compared to wget and cp
  #remote_file "Get SAP_HANA_PACKAGE.SAR file" do
  #    source "#{params[:bin_file_url]}"
  #    path "#{node['install']['tempdir']}/SAP_HANA_PACKAGE.SAR"
  #    backup false
  #end
  
  execute "Extract Hana binary package" do
    cwd "#{node['install']['tempdir']}"
    command "chmod +x SAPCAR && ./SAPCAR -xvf SAP_HANA_PACKAGE.SAR"
  end

  execute "Delete the installer archive to save some disk space" do
    cwd "#{node['install']['tempdir']}"
    command "rm -f SAP_HANA_PACKAGE.SAR"
  end

  execute "Start install / upgrade HANA server / client" do
    cwd "#{node['install']['tempdir']}/#{params[:bin_dir]}"
    command "#{params[:exe]}"
  end

  directory "Delete temporary directory" do
    path "#{node['install']['tempdir']}"
    recursive true
    action :delete
  end

end
