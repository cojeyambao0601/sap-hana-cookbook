define :hdbcmd, :exe => "", :bin_dir => "", :bin_file_url => "" do

  directory "Create temporary directory" do
    path "#{node['install']['tempdir']}"
    action :create
    recursive true
  end

  execute "Get SAPCAR tool for Hana extracting hana package" do
    cwd "#{node['install']['tempdir']}"
    command "wget #{node['install']['files']['sapcar']}"
  end

  execute "Get Hana binary package" do
    cwd "#{node['install']['tempdir']}"
    command "wget #{params[:bin_file_url]} -O SAP_HANA_PACKAGE.SAR"
  end

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
