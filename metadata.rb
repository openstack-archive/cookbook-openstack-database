name             'openstack-database'
maintainer       'openstack-chef'
maintainer_email 'opscode-chef-openstack@googlegroups.com'
license          'Apache 2.0'
description      'Installs/Configures trove'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '10.0.0'
recipe           'openstack-database::identity_registration', 'Registers Trove endpoints and service with Keystone'
recipe           'openstack-database::api', 'Installs API service'
recipe           'openstack-database::conductor', 'Installs Conductor service'
recipe           'openstack-database::taskmanager', 'Installs TaskManager service'

depends          'openstack-common', '>= 10.2.0'
depends          'openstack-identity', '>= 10.0.0'

supports 'suse'
