# encoding: UTF-8

require_relative 'spec_helper'

describe 'openstack-database::identity_registration' do
  describe 'suse' do
    let(:runner) { ChefSpec::Runner.new(SUSE_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) { runner.converge(described_recipe) }

    include_context 'database-stubs'

    it 'registers service tenant' do
      expect(chef_run).to create_tenant_openstack_identity_register(
        'Register Service Tenant'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        tenant_name: 'service',
        tenant_description: 'Service Tenant'
      )
    end

    it 'registers service user' do
      expect(chef_run).to create_user_openstack_identity_register(
        'Register Service User'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        tenant_name: 'service',
        user_name: 'trove',
        user_pass: 'service-pass'
      )
    end

    it 'grants admin role to service user for service tenant' do
      expect(chef_run).to grant_role_openstack_identity_register(
        "Grant 'admin' Role to Service User for Service Tenant"
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        tenant_name: 'service',
        user_name: 'trove',
        role_name: 'admin'
      )
    end

    it 'registers database service' do
      expect(chef_run).to create_service_openstack_identity_register(
        'Register Database Service'
      ).with(
        auth_uri: 'http://127.0.0.1:35357/v2.0',
        bootstrap_token: 'bootstrap-token',
        service_name: 'trove',
        service_type: 'database',
        service_description: 'Trove Service'
      )
    end

    context 'registers database endpoint' do
      it 'with default values' do
        expect(chef_run).to create_endpoint_openstack_identity_register(
          'Register Database Endpoint'
        ).with(
          auth_uri: 'http://127.0.0.1:35357/v2.0',
          bootstrap_token: 'bootstrap-token',
          service_type: 'database',
          endpoint_region: 'RegionOne',
          endpoint_adminurl: 'http://127.0.0.1:8779/v1.0/%(tenant_id)s',
          endpoint_internalurl: 'http://127.0.0.1:8779/v1.0/%(tenant_id)s',
          endpoint_publicurl: 'http://127.0.0.1:8779/v1.0/%(tenant_id)s'
        )
      end
    end
  end
end
