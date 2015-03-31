# encoding: UTF-8

require 'chefspec'
require 'chefspec/berkshelf'
require 'chef/application'

LOG_LEVEL = :fatal
SUSE_OPTS = {
  platform: 'suse',
  version: '11.3',
  log_level: ::LOG_LEVEL
}
REDHAT_OPTS = {
  platform: 'redhat',
  version: '7.1',
  log_level: ::LOG_LEVEL
}
UBUNTU_OPTS = {
  platform: 'ubuntu',
  version: '14.04',
  log_level: ::LOG_LEVEL
}

shared_context 'database-stubs' do
  before do
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('token', 'openstack_identity_bootstrap_token')
      .and_return('bootstrap-token')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'guest').and_return('rabbit-pass')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('db', 'database').and_return('db-pass')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('service', 'database').and_return('service-pass')
    allow_any_instance_of(Chef::Recipe).to receive(:get_password)
      .with('user', 'database').and_return('user-pass')
  end
end
