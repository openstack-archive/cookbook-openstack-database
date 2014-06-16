require "chefspec"
require "chefspec/berkshelf"
require "chef/application"

::LOG_LEVEL = :fatal
::SUSE_OPTS = {
  :platform => "suse",
  :version => "11.03",
  :log_level => ::LOG_LEVEL
}
::REDHAT_OPTS = {
  :platform => "redhat",
  :version => "6.3",
  :log_level => ::LOG_LEVEL
}
::UBUNTU_OPTS = {
  :platform => "ubuntu",
  :version => "12.04",
  :log_level => ::LOG_LEVEL
}

shared_context 'database-stubs' do
  before do
    Chef::Recipe.any_instance.stub(:secret)
      .with('secrets', 'openstack_identity_bootstrap_token').and_return('bootstrap-token')
    Chef::Recipe.any_instance.stub(:get_password).
      with('user', 'guest').and_return('rabbit-pass')
    Chef::Recipe.any_instance.stub(:get_password).
      with('db', 'openstack-database').and_return('db-pass')
  end
end
