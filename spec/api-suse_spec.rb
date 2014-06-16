require_relative "spec_helper"

describe "openstack-database::api" do
  let(:runner) { ChefSpec::Runner.new(SUSE_OPTS) }
  let(:node) { runner.node }
  let(:chef_run) { runner.converge(described_recipe) }

  include_context 'database-stubs'

  it "installs the api packages" do
    expect(chef_run).to install_package('openstack-trove-api')
  end

  it "starts the api service" do
    expect(chef_run).to enable_service("openstack-trove-api")
  end

  it "includes the logging recipe if syslog is enabled" do
    chef_run = ChefSpec::Runner.new(::SUSE_OPTS) do |node|
      node.set['openstack']['database']['syslog']['use'] = true
    end.converge('openstack-database::api')

    expect(chef_run).to include_recipe 'openstack-common::logging'
  end

  describe "trove.conf" do
    let(:filename) { "/etc/trove/trove.conf" }

    it "creates trove.conf file" do
      expect(chef_run).to create_template(filename).with(
        user: "trove",
        group: "trove",
        mode: 0640
        )
    end

    [/^debug = false$/,
      /^verbose = false$/,
      /^sql_connection = mysql:\/\/trove:db-pass\@127\.0\.0\.1:3306\/trove\?charset=utf8/,
      /^bind_host = 127.0.0.1$/,
      /^bind_port = 8779$/,
      /^rabbit_host = 127.0.0.1$/,
      /^rabbit_virtual_host = \/$/,
      /^rabbit_port = 5672$/,
      /^rabbit_userid = guest$/,
      /^rabbit_password = rabbit-pass$/,
      /^rabbit_use_ssl = false$/,
      /^trove_auth_url = http:\/\/127.0.0.1:5000\/v2.0$/,
      /^nova_compute_url = http:\/\/127.0.0.1:8774\/v2\/$/,
      /^cinder_url = http:\/\/127.0.0.1:8776\/v1\/$/,
      /^swift_url = http:\/\/127.0.0.1:8080\/v1\/$/,
      /^dns_auth_url = http:\/\/127.0.0.1:5000\/v2.0$/,
      /^log_dir = \/var\/log\/trove$/,
      /^trove_volume_support = true$/
    ].each do |content|
      it "has a \"#{content.source[1...-1]}\" line" do
        expect(chef_run).to render_file(filename).with_content(content)
      end
    end
  end

  describe "api-paste.ini" do
    let(:filename) { "/etc/trove/api-paste.ini" }

    it "creates the file" do
      expect(chef_run).to create_template(filename).with(
        user: "trove",
        group: "trove",
        mode: 0640
        )
    end

    [/^auth_uri = http:\/\/127.0.0.1:5000\/v2.0$/,
      /^auth_host = 127.0.0.1$/,
      /^auth_port = 35357$/,
      /^auth_protocol = http$/,
      /^signing_dir = \/var\/cache\/trove\/api$/
        ].each do |content|
      it "has a \"#{content.source[1...-1]}\" line" do
        expect(chef_run).to render_file(filename).with_content(content)
      end
    end
  end

  describe "database initialization" do
    let(:manage_cmd) { "trove-manage db_sync" }

    it "runs trove-manage" do
      expect(chef_run).to run_execute(manage_cmd)
    end

    it "restarts the trove-api service" do
      res = chef_run.execute(manage_cmd)
      expect(res).to notify("service[trove-api]").to(:restart)
    end
  end
end
