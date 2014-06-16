#
# Cookbook Name:: openstack-database
# Recipe:: guestagent
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

platform_options = node['openstack']['database']['platform']

platform_options['guestagent_packages'].each do |pkg|
  package pkg
end

service 'trove-guestagent' do
  service_name platform_options['guestagent_service']
  supports status: true, restart: true

  action [:enable]
end

guestagent_endpoint = endpoint('database-guestagent')

db_user = node['openstack']['db']['database']['username']
db_pass = get_password 'db', 'openstack-database'
db_uri = db_uri('database', db_user, db_pass).to_s

identity_uri = endpoint('identity-api')
object_storage_uri = endpoint('object-storage-api')

rabbit = node['openstack']['mq']['database']['rabbit']
rabbit_pass = get_password('user', rabbit['userid'])

template '/etc/trove/trove-guestagent.conf' do
  source 'trove-guestagent.conf.erb'
  owner node['openstack']['database']['user']
  group node['openstack']['database']['group']
  mode 00640
  variables(
    database_connection: db_uri,
    rabbit: rabbit,
    rabbit_pass: rabbit_pass,
    endpoint: guestagent_endpoint,
    identity_uri: identity_uri,
    object_storage_uri: object_storage_uri
    )

  notifies :restart, 'service[trove-guestagent]', :immediately
end
