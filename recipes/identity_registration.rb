# encoding: UTF-8
#
# Cookbook Name:: openstack-database
# Recipe:: identity_registration
#
# Copyright 2013-2014, SUSE Linux GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'uri'

class ::Chef::Recipe # rubocop:disable Documentation
  include ::Openstack
end

identity_admin_endpoint = admin_endpoint 'identity-admin'
bootstrap_token = get_password('token', 'openstack_identity_bootstrap_token')
auth_uri = ::URI.decode identity_admin_endpoint.to_s
service_pass = get_password 'service', 'database'
service_user = node['openstack']['database']['service_user']
service_role = node['openstack']['database']['service_role']
service_tenant_name = node['openstack']['database']['service_tenant_name']
admin_database_service_api_endpoint = admin_endpoint 'database-api'
internal_database_service_api_endpoint = internal_endpoint 'database-api'
public_database_service_api_endpoint = public_endpoint 'database-api'
region = node['openstack']['database']['region']

# Register Service Tenant
openstack_identity_register 'Register Service Tenant' do
  auth_uri auth_uri
  bootstrap_token bootstrap_token
  tenant_name service_tenant_name
  tenant_description 'Service Tenant'

  action :create_tenant
end

# Register Service User
openstack_identity_register 'Register Service User' do
  auth_uri auth_uri
  bootstrap_token bootstrap_token
  tenant_name service_tenant_name
  user_name service_user
  user_pass service_pass

  action :create_user
end

## Grant Service role to Service User for Service Tenant ##
openstack_identity_register "Grant '#{service_role}' Role to Service User for Service Tenant" do
  auth_uri auth_uri
  bootstrap_token bootstrap_token
  tenant_name service_tenant_name
  user_name service_user
  role_name service_role

  action :grant_role
end

# Register Database Service Service
openstack_identity_register 'Register Database Service' do
  auth_uri auth_uri
  bootstrap_token bootstrap_token
  service_name 'trove'
  service_type 'database'
  service_description 'Trove Service'

  action :create_service
end

# Register Database Service Endpoint
openstack_identity_register 'Register Database Endpoint' do
  auth_uri auth_uri
  bootstrap_token bootstrap_token
  service_type 'database'
  endpoint_region region
  endpoint_adminurl ::URI.decode admin_database_service_api_endpoint.to_s
  endpoint_internalurl ::URI.decode internal_database_service_api_endpoint.to_s
  endpoint_publicurl ::URI.decode public_database_service_api_endpoint.to_s

  action :create_endpoint
end
