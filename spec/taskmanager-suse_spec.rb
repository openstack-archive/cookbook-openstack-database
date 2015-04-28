# encoding: UTF-8

require_relative 'spec_helper'

describe 'openstack-database::taskmanager' do
  let(:runner) { ChefSpec::SoloRunner.new(SUSE_OPTS) }
  let(:node) { runner.node }
  let(:chef_run) { runner.converge(described_recipe) }

  include_context 'database-stubs'

  it 'installs the taskmanager packages' do
    expect(chef_run).to install_package('openstack-trove-taskmanager')
  end

  it 'starts the taskmanager service' do
    expect(chef_run).to enable_service('openstack-trove-taskmanager')
  end

  describe 'trove-taskmanager.conf' do
    let(:filename) { '/etc/trove/trove-taskmanager.conf' }

    it 'creates trove-taskmanager.conf file' do
      expect(chef_run).to create_template(filename).with(
        user: 'trove',
        group: 'trove',
        mode: 0640
        )
    end

    it 'has the default values for configurable attributes' do
      [/^debug = false$/,
       /^verbose = false$/,
       %r{^sql_connection = mysql://trove:db-pass@127.0.0.1:3306/trove\?charset=utf8},
       /^rabbit_host = 127.0.0.1$/,
       /^rabbit_virtual_host = \/$/,
       /^rabbit_port = 5672$/,
       /^rabbit_userid = guest$/,
       /^rabbit_password = rabbit-pass$/,
       /^rabbit_use_ssl = false$/,
       %r{^trove_auth_url = http://127.0.0.1:5000/v2.0$},
       %r{^nova_compute_url = http://127.0.0.1:8774/v2/$},
       %r{^cinder_url = http://127.0.0.1:8776/v2/$},
       %r{^swift_url = http://127.0.0.1:8080/v1/AUTH_%\(tenant_id\)s$},
       %r{^dns_auth_url = http://127.0.0.1:5000/v2.0$},
       %r{^log_dir = /var/log/trove},
       /^trove_volume_support = true$/
      ].each do |content|
        expect(chef_run).to render_file(filename).with_content(content)
      end
    end
  end
end
