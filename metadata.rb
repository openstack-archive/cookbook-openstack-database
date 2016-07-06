name 'openstack-database'
maintainer 'openstack-chef'
maintainer_email 'openstack-dev@lists.openstack.org'
issues_url 'https://launchpad.net/openstack-chef' if respond_to?(:issues_url)
source_url 'https://github.com/openstack/cookbook-openstack-database' if respond_to?(:source_url)
license 'Apache 2.0'
description 'Installs/Configures trove'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '12.0.0'
recipe 'openstack-database::identity_registration', 'Registers Trove endpoints and service with Keystone'
recipe 'openstack-database::api', 'Installs API service'
recipe 'openstack-database::conductor', 'Installs Conductor service'
recipe 'openstack-database::taskmanager', 'Installs TaskManager service'

depends 'openstack-common', '>= 12.0.0'
depends 'openstack-identity', '>= 12.0.0'

supports 'suse'
