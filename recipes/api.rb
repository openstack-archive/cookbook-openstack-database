# encoding: UTF-8
#
# Cookbook Name:: openstack-database
# Recipe:: api
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

class ::Chef::Recipe # rubocop:disable Documentation
  include ::Openstack
end

if node['openstack']['database']['syslog']['use']
  include_recipe 'openstack-common::logging'
end

platform_options = node['openstack']['database']['platform']

platform_options['api_packages'].each do |pkg|
  package pkg
end

service 'trove-api' do
  service_name platform_options['api_service']
  supports status: true, restart: true

  action [:enable]
end

db_user = node['openstack']['db']['database']['username']
db_pass = get_password 'db', 'database'
db_uri = db_uri('database', db_user, db_pass).to_s

api_endpoint = internal_endpoint 'database-api'

identity_uri = internal_endpoint('identity-internal')
compute_uri = internal_endpoint('compute-api').to_s.gsub(/%\(tenant_id\)s/, '')
block_storage_uri = internal_endpoint('block-storage-api').to_s.gsub(/%\(tenant_id\)s/, '')
object_storage_uri = internal_endpoint('object-storage-api')

rabbit = node['openstack']['mq']['database']['rabbit']
rabbit_pass = get_password('user', rabbit['userid'])

template '/etc/trove/trove.conf' do
  source 'trove.conf.erb'
  owner node['openstack']['database']['user']
  group node['openstack']['database']['group']
  mode 00640
  variables(
    database_connection: db_uri,
    endpoint: api_endpoint,
    rabbit: rabbit,
    rabbit_pass: rabbit_pass,
    identity_uri: identity_uri,
    compute_uri: compute_uri,
    block_storage_uri: block_storage_uri,
    object_storage_uri: object_storage_uri
  )

  notifies :restart, 'service[trove-api]', :immediately
end

admin_token = get_password('token', 'openstack_identity_bootstrap_token')
identity_admin_uri = admin_endpoint('identity-admin')

directory ::File.dirname(node['openstack']['database']['api']['auth']['cache_dir']) do
  owner node['openstack']['database']['user']
  group node['openstack']['database']['group']
  mode 00700
end

template '/etc/trove/api-paste.ini' do
  source 'api-paste.ini.erb'
  owner node['openstack']['database']['user']
  group node['openstack']['database']['group']
  mode 00640
  variables(
    identity_admin_uri: identity_admin_uri,
    identity_uri: identity_uri,
    admin_token: admin_token
  )

  notifies :restart, 'service[trove-api]', :immediately
end

execute 'trove-manage db_sync' do
  user node['openstack']['database']['user']
  group node['openstack']['database']['group']
  notifies :restart, 'service[trove-api]', :immediately
  not_if { platform_family? 'suse' }
end
