Description 
===========
This cookbook provides recipes for installing and updating SAP Hana database and SAP Hana client.

Requirements
===========
### Platform

* Suse SLES 11 SP2 (check [PAM](https://service.sap.com/sap/support/pam) for changes)
* approx. 5GB in the directory specified in attribute `['install'].['tempdir']`

### Attributes

All attributes have sane default values (See `attributes/default.rb`). You can install any supported component in this cookbook, without overriding any attributes. In case you need to override an attribute(s), use either a role or a wrapper cookbook. See examples in the examples section.

#### Attributes related to SAP Hana instance configuration.

* `['hana'].['installpath']` - the directory into which SAP Hana will be installed. If this is overridden to something other than **/usr/sap**, then /usr/sap will be symlinked to the chosen location. **ATTENTION:** an existing directory /usr/sap will be DELETED before symlink is created!
* `['hana'].['datapath']` - custom path for the data files, empty by default
* `['hana'].['logpath']` - custom path for the data files, empty by default
* `['hana'].['sid']` - the SID of the installation
* `['hana'].['instance']` - the instance number of the installation
* `['hana'].['userid']` - UID of the user SIDadm, which will be created during installation
* `['hana'].['password']` - SIDadm's password
* `['hana'].['syspassword']` - password for database user SYSTEM
* `['hana'].['checkhardware']` - flag to circumvent SAP's check, whether the used hardware is certified and meets certain requirements. Bear in mind that this is **not** meant for production systems, and don't expect any support.
* `['hana'].['checkstoignore']` - installer checks to be ignored if the checkhardware flag is disabled
* `['hana'].['clientsid']` - flag to specify a stand-alone Hana client installation (see below)

#### Attributes related to the installation process.
* `['install'].['tempdir']` - temporary directory needed during installation
* `['install'].['files'].['sapcar']` - URL to the SAPCAR tool (for extracting SAR files)
* `['install'].['files'].['hanadb']` - URL to the SAR file for the Hana installer
* `['install'].['files'].['hanaclient']` - URL to the SAR file for the Hana client installer

All attributes under ['install'].['files'] hierarchy, must be accessible by http get method from the node on which the installation is executed.
The structure of ['install'].['files'].['hanadb'] archive must be a sole folder named SAP_HANA_DATABASE and all installation files in it.
The structure of ['install'].['files'].['hanadb'] archive must be a sole folder named SAP_HANA_CLIENT and all installation files in it.

#### Attributes related to the distributed installation process.

* `['hana'].['dist'].['sharedvolume']` - the nfs path (i.e server:/path) to the shared disk where the HANA will be installed including the data files and the log files. Only NFS shares are supported now. This attribute should be either an empty string or not set at all in case of a single node installation.
* `['hana'].['dist'].['sharedmountoptions']` - The NFS share options.
* `['hana'].['dist'].['waitcount']` - The number of wait loops for the NFS share to be available. Needed in case of distributed installation where the NFS share is being created in parallel to the SAP Hana node installations. Usually keep the defaults.
* `['hana'].['dist'].['waittime']` - How much time each loop will wait. Usually keep the defaults.

All attributes under ['hana'].['dist'] hierarchy are related to distributed SAP Hana system installation process. Override only if you are installing a distributed system.


---
Recipes
===========
### hana::install
Installs single SAP Hana database on the node. 

### hana::upgrade
Recipe for upgrading an existing installation of SAP Hana on the node.

### hana::install-client
Installs SAP Hana client on the node. The client will be installed into `['hana']['installpath']`/hdbclient.  
The SAP Hana client installer accepts a parameter "*-s SID*", thereby "coupling" the client to a SAP Hana installation with the given SID on the same node.  
If a stand-alone installation of the SAP Hana client is desired (i.e. there is **no** SAP Hana installation on the node), set the node attribute `['hana']['clientsid']` to "false".

### hana::upgrade-client
Recipe for upgrading an existing installation of SAP Hana client on the node.  
As with the **[hana::install-client]** recipe, the node attribute `['hana']['clientsid']` needs to be set to "false" if this is a stand-alone client installation.

### hana::install-worker
Recipe to add a worker node to existing SAP Hana distributed cluster. To use this recipe you must provide the shared storage information by overriding the attribute ['hana'].['dist'].['sharedvolume']. See examples of distributed installation below.

---
Usage
===========
### Single SAP Hana node
Add the **[hana::install]** recipe to a new node in your landscape if you're planning a vanilla installation of SAP Hana. Change/override any attributes as required.

#### Example
To install SAP Hana on a node, and override the installation path and the SYSTEM user password use the following role:

	
	name "hana-install-single"
	description "Role for installing SAP Hana server"

	override_attributes(
	  "hana" => {
	    "installpath" => "/your/path/hana",
	    "syspassword" => "YOUR-SECRET"
	  }
	)

	run_list "recipe[hana::install]"

### SAP Hana client on a node
For installing SAP Hana client on a node in your landscape, add the **[hana::install-client]** recipe to the node's run list. If it should be a stand-alone installation of SAP Hana client, set a node attribute `['hana']['clientsid']` to "false".

#### Example
To install SAP Hana client on a node, use the following role:

	name "hana-install-client"
	description "Role for installing SAP Hana client"

	override_attributes(
	  "hana" => {
	    "installpath" => "/your/path/hana"
	  }
	)

	run_list "recipe[hana::install-client]"

### Updrading existing SAP Hana installations
The recipes **[hana::upgrade]** and **[hana::upgrade-client]** - as the names imply - will upgrade an existing SAP Hana and SAP Hana client, respectively.  
Ensure that the upgrade packages are accessible by setting the node attributes `['install']['files']['hanadb']` and `['install']['files']['hanaclient']` accordingly.

### Distributed SAP Hana cluster
To install a distributed SAP Hana cluster you must have a shared NFS share prepared. You can use chef NFS cookbook for this, or manually create NFS share. Once the share is avalable you must provide the share information in the attribute ['hana'].['dist'].['sharedvolume']. This is needed for the first node (master) and the other nodes (workers). The master node is installed by using the hana:install recipe and the workers are installed by using the hana:install-worker recipe.

#### Example
Assuming we have NFS share exported on your-nfs-node.yourdomain.com:/some/export/hana . To install the master node use the following role:

	name "hana-install-master"
	description "Role for installing SAP Hana master node in a distributed environment"

	override_attributes(
		"hana" => {
			"installpath" => "/your/path/hana",
			"dist" => {
				"sharedvolume" => "your-nfs-node.yourdomain.com:/some/export/hana",
				"sharedmountoptions" => "rw"
			}
		}
	)

	run_list "recipe[hana::install]"

This will mount the sharedvolume on your loclal installpath "/your/path/hana" and install the master SAP Hana database instance in it.
Then use the following role to add new worker nodes to the cluster:

	name "hana-install-worker"
	description "Role for installing SAP Hana worker node in a distributed environment"

	override_attributes(
		"hana" => {
			"installpath" => "/your/path/hana",
			"dist" => {
				"sharedvolume" => "your-nfs-node.yourdomain.com:/some/export/hana",
				"sharedmountoptions" => "rw"
			}
		}
	)

	run_list "recipe[hana::install-worker]"

---
Provided LWRP
===============
The LWRP which are incuded with this cookbook are wrapping different hana client utilities. This is very useful when you need to automate different hana related tasks with chef automation. Operations like schema creation, execution of sql commands or files with sql commands and various hana repository operations are supported. You can use any provided resource on any machine where you are using the hana client recipe (install-client).

### hana\_hdbsql 

#### Description

Applications or other cookbooks can use the hana\_hdbsql resource to run sql commands or execute a list of commands from a .sql file.

#### Usage

To use hana_runsql command, you must specify the following parameters:
* sql_command or sql_file_path
   - sql_command - a single command to run
   - sql_file_path - full path to .sql file which may contain multiple commands / sql statements
* username
   - The DB username under which the session will run:
* password
   - The DB user passowrd
* sql_file_command_separator
   - if you are using sql_file_path option, you can specify which command separator in the file is used
   - defaults to ;
   - optional
* host
   - the host name on which the hana database is installed
   - defaults to localhost
   - optional
* instance_number
   - the hana db instance number
   - defaults to 00
   - optional
* print_sql_commands
   - boolean. if set to true the executed sql commands will be outputed before the command output
   - defaults to true
* print_table_header
   - boolean. if set to true in the select statemets will output the table headers
   - defaults to true
* output_file_path
   - if set, will write the command output to a file instead of writing it to stdout
   - defaults to none, which means that the outout will be sent to stdout
#### Examples

To run a SQL command directly:

	hana_runsql "select some rows from a table" do
		sql_command "SELECT * FROM \"MYSCHEMA\".\"MYTABLENAME\""
		username "YOUR-HANA-USER-NAME"
		password "YOUR-HANA-USER-PASSWORD"
	end

To execute a list of commands from .sql file:

	hana_runsql "hana_runsql from file - /mydir/mysqlfile.sql" do
		sql_file_path "/mydir/mysqlfile.sql"
		username "YOUR-HANA-USER-NAME"
		password "YOUR-HANA-USER-PASSWORD"
	end

To execute a SQL command, and write output to a file without table headers or the command itself:

	hana_hdbsql "Check number of documents in the view" do
		sql_command "SELECT count(distinct \"id\") as count FROM \"_SYS_BIC\".\"srch/AV_DOCS_GRP_CONTENT_MD\""
		print_sql_commands false
		print_table_header false         
		username "SRCH"
		username "YOUR-HANA-USER-NAME"
		password "YOUR-HANA-USER-PASSWORD"
	end

### hana\_hdbuserstore

#### Description

In SAP Hana, automation around the content repository is done via the regi command line utility. To be able to use the regi command, you need to initialize a local user store, which will contain authentication information to your SAP Hana system. Use the hana\_hdbuserstore resource to create / delete local user stores befause any regi usage.

#### Usage

The hana_hdbuserstore resource has 2 actions: set and delete.

The set action is used to create a new user store. The delete action is used to remove existing user store.

Here are the accepted arguments:
* action
   - Action, can be set or delete. 
   - default action is set
   - optional
* key
   - Name attribute
   - The workspace key is a unique identifier
   - mandatory
* username
   - The DB user name
   - optional for delete action, mandatory for set
* password
   - The DB user passowrd
   - optional for delete action, mandatory for set
* host
   - the host name on which the hana database is installed
   - defaults host is localhost
   - optional
* instance_number
   - the hana db instance number
   - defaults instance_number is 00
   - optional

#### Examples

To add a new store with key "buildkey":

	# create hdbuserstore
	hana_hdbuserstore "buildkey" do
		username "SYSTEM"
		password "SYSTEM user password"
	end

To remove a store with key "buildkey":

	# remove workspace
	hana_hdbuserstore "buildkey" do
		action :delete
	end

### hana\_regi

#### Description

The regi command line utility is used to automate operations around the HANA repository. HANA repository is source control like system (but not only), which comes with SAP Hana, and allows to import / export software packages, create / delete / manipulate views (attribute, analytical, calculation) and additional operations. This resource allows to automate regi tasks with chef, which is very useful for automating SAP Hana application development tasks, and continous deployment tasks of applications which run on top of SAP Hana.

#### Usages

##### regi workspace operations
The hana_regi has 2 actions which relate to creation and removal of a regi workspace: create_workspace and delete_workspace. A workspace is a local instance of the SAP Hana repository. To execute any repository operation you have to create a workspace first.

##### Examples

To add a new workspace using the user store with key "buildkey":

	# create workspace
	hana_regi "create repository workspace" do
		key "buildkey"
		workspace_path "/your/path/to/new/workspace"
		action :create_workspace
	end

To remove a workspace with key "buildkey":

	# remove workspace
	hana_regi "Delete workspace" do
		workspace_path "#{regi_workspace}"
		action :delete_workspace
	end

##### regi delivery unit operations
The hana_regi has 2 actions which relate to delivery unit mechanism: export_delivery_unit and import_delivery_unit. A delivery unit in SAP Hana is usually a package of application code, view, tables and data. You can use export_delivery_unit action to export code from existing development machine into a archved file, and import_delivery_unit to import the same archive into a different system. This can be useful in continuous integration / delivery process. In addition when installing a new SAP Hana instance, you might want to import existing applications / functionality which comes with SAP Hana installation in the form of optional delivery units. Examples to this are INA services and UI toolkits and Custom Text analytics dictinaries.

##### Examples

To import a delivery unit use:

	# import INA UI toolkit
	hana_regi "Import INA UI Toolkit delivery unit" do
		delivery_unit_path "#{node['hana']['installpath']}/#{node['hana']['sid']}/global/hdb/content/HCO_INA_UITOOLKIT.tgz"
		workspace_path "#{regi_workspace}"
		action :import_delivery_unit
	end

To export a delivery unit use:

	# export DU, this will export the package com.sap.someapp to a file in /your/export/path/com.sap.someapp.tgz
	hana_regi "Export delivery unit" do
		delivery_unit_name "com.sap.someapp"
		delivery_unit_vendor "sap"
		delivery_unit_path "/your/export/path/"
		workspace_path "#{regi_workspace}"
		action :import_delivery_unit
	end

##### regi package operations
The hana_regi has 3 actions which relate to management of packages: track_package, untrack_package and delete_package. Packages in hana are simmilar to packages in Java, and are used to bundle together application files which relates to the same topic. Use track_package if you want to work on a specific package on you local workspace. Use untrack_package to remove a workspace link to a packge. Use delete_package to delete the contents of a package from the local workspace and from the local file system

##### Examples

To track a package "mypackage.app"

	# track
	hana_regi "Track package mypackage.app" do
		package "mypackage.app"
		workspace_path "#{regi_workspace}"
		action :track_package
	end

To untrack a package "mypackage.app"

	# track
	hana_regi "Un track package mypackage.app" do
		package "mypackage.app"
		workspace_path "#{regi_workspace}"
		action :untrack_package
	end

To delete a package "mypackage.app"

	# completely delete
	hana_regi "Delete package mypackage.app" do
		workspace_path "#{regi_workspace}"
		package "mypackage.app"
		action :delete_package
	end

##### regi repository operations
The hana_regi has 4 actions which relate to repository manipulation: checkout, commit, activate, and revert. These are similar to common source control repository operations, and allow to checkout, commit and revert files. In addition there is an action which activates the application in the repository, and applies it to the SAP Hana system. An example to activation is activation of attribute / analytical / calculation views. But also other artifacts might be in a need of activation before they can be used in productive manner.

##### Examples

Some useful examples of how to use checkout

	# checkout
	hana_regi "Checkout package mypackage.app" do
		workspace_path "#{regi_workspace}"
		force true
		package "mypackage.app"
		action :checkout
	end
	
	# checkout
	hana_regi "Checkout package mypackage.app and it's sub packages" do
		workspace_path "#{regi_workspace}"
		force true
		packages "mypackage.app"
		action :checkout
	end
	
	# checkout
	hana_regi "Checkout all tracked objects" do
		workspace_path "#{regi_workspace}"
		force true
		object_type "trackedPackages"
		action :checkout
	end
	
	# checkout
	hana_regi "Checkout a file" do
		workspace_path "#{regi_workspace}"
		force true
		object "/my/path/to/a/tracked/file"
		action :checkout
	end

Some useful examples of how to use commit

	# commit
	hana_regi "Commit package mypackage.app" do
		workspace_path "#{regi_workspace}"
		force true
		package "mypackage.app"
		action :commit
	end
	
	# commit
	hana_regi "Commit package mypackage.app and it's sub packages" do
		workspace_path "#{regi_workspace}"
		force true
		packages "mypackage.app"
		action :commit
	end
	
	# commit
	hana_regi "Commit all tracked objects" do
		workspace_path "#{regi_workspace}"
		force true
		object_type "trackedPackages"
		action :commit
	end
	
	# commit
	hana_regi "Commit a file" do
		workspace_path "#{regi_workspace}"
		force true
		object "/my/path/to/a/tracked/file"
		action :commit
	end

Some useful examples of how to use revert

	# revert
	hana_regi "Revert package mypackage.app" do
		workspace_path "#{regi_workspace}"
		force true
		package "mypackage.app"
		action :revert
	end
	
	# revert
	hana_regi "Revert package mypackage.app and it's sub packages" do
		workspace_path "#{regi_workspace}"
		force true
		packages "mypackage.app"
		action :revert
	end
	
	# revert
	hana_regi "Revert all tracked objects" do
		workspace_path "#{regi_workspace}"
		force true
		object_type "trackedPackages"
		action :revert
	end
	
	# revert
	hana_regi "Revert all inactive objects" do
		workspace_path "#{regi_workspace}"
		force true
		object_type "inactiveObjects"
		action :revert
	end
	
	
	# revert
	hana_regi "Revert a file" do
		workspace_path "#{regi_workspace}"
		force true
		object "/my/path/to/a/tracked/file"
		action :revert
	end

Some useful examples of how to use activate

	# activate
	hana_regi "Activate package mypackage.app" do
		workspace_path "#{regi_workspace}"
		force true
		package "mypackage.app"
		action :activate
	end
	
	# activate
	hana_regi "Activate package mypackage.app and it's sub packages" do
		workspace_path "#{regi_workspace}"
		force true
		packages "mypackage.app"
		action :activate
	end
	
	# activate
	hana_regi "Activate all tracked objects" do
		workspace_path "#{regi_workspace}"
		force true
		object_type "trackedPackages"
		action :activate
	end
	
	# activate
	hana_regi "Activate all inactive objects" do
		workspace_path "#{regi_workspace}"
		force true
		object_type "inactiveObjects"
		action :activate
	end
	
	
	# activate
	hana_regi "Activate a file" do
		workspace_path "#{regi_workspace}"
		force true
		object "/my/path/to/a/tracked/file"
		action :activate
	end

---
Real world full examples of hana resources
===============

### Create regi workspace, use regi .. then remove the store and the workspace

#### Usage

	# create new store
	hana_hdbuserstore "buildkey" do
		username "SYSTEM"
		password "#{node['hana']['password']}"
		action :set
	end
	
	# create the repository workspace
		hana_regi "create workspace" do
		path regi_workspace
		key "buildkey"
		action :create_workspace
	end

	#### use regi to activate all inactive objects
	hana_regi "Activate inactive objects for example added attribute views" do
		workspace_path "#{regi_workspace}"
		object_type "inactiveObjects"
		action :activate
	end	

	# remove store
	hana_hdbuserstore "buildkey" do
		action :delete
	end

	hana_regi "Delete workspace" do
		workspace_path "#{regi_workspace}"
		action :delete_workspace
	end	

### Use hdbsql command to check how many rows we have in a given attribute view

#### Usage

	hana_hdbsql "Check number of documents in the view" do
		sql_command "SELECT count(distinct \"id\") as count FROM \"_SYS_BIC\".\"your_package/AV_YOUR_VIEW_NAME\""
		print_sql_commands false
		print_table_header false			
		username "SRCH"
		password "#{node['youruser']['yourpassword']}"
	end

### Use regi command to import INA UI and services delivery units

#### Usage

	# create new store
	hana_hdbuserstore "buildkey" do
		username "SYSTEM"
		password "#{node['hana']['password']}"
		action :set
	end
	
	# create the repository workspace
		hana_regi "create workspace" do
		path regi_workspace
		key "buildkey"
		action :create_workspace
	end

	hana_regi "Import INA UI Toolkit delivery unit" do
		delivery_unit_path "#{node['hana']['installpath']}/#{node['hana']['sid']}/global/hdb/content/HCO_INA_UITOOLKIT.tgz"
		workspace_path "#{regi_workspace}"
		action :import_delivery_unit
	end

	hana_regi "Import INA Service delivery unit" do
		delivery_unit_path "#{node['hana']['installpath']}/#{node['hana']['sid']}/global/hdb/content/HCO_INA_SERVICE.tgz"
		workspace_path "#{regi_workspace}"
		action :import_delivery_unit
	end

	# remove store
	hana_hdbuserstore "buildkey" do
		action :delete
	end

	hana_regi "Delete workspace" do
		workspace_path "#{regi_workspace}"
		action :delete_workspace
	end

### Use hdbsql command to run a sql script which contains your create schema sql ddl statements

#### Usage

	["create-schema.sql"].each do |file|
		cookbook_file "#{temp_dir}/#{file}" do
		  source "#{file}"
		  mode 0644
		  owner "root"
		  group "root"
		end

		hana_hdbsql "hana_hdbsql from file - #{file}" do
			sql_file_path "#{temp_dir}/#{file}"
			username "#{node['yourapp']['your-user-name']}"
			password "#{node['yourapp']['your-user-password']}"
		end	
	end
