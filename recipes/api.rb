# encoding: UTF-8
#
# Cookbook Name:: openstack-orchestration
# Recipe:: api
#
# Copyright 2013, IBM Corp.
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

include_recipe 'openstack-orchestration::common'

platform_options = node['openstack']['orchestration']['platform']

platform_options['heat_api_packages'].each do |pkg|
  package pkg do
    options platform_options['package_overrides']

    action :upgrade
  end
end

service 'heat-api' do
  service_name platform_options['heat_api_service']
  supports status: true, restart: true

  action :enable
  subscribes :restart, 'template[/etc/heat/heat.conf]'
end

template '/etc/heat/api-paste.ini' do
  only_if { node['openstack']['orchestration']['handle_api_paste_ini'] }
  source 'api-paste.ini.erb'
  group  node['openstack']['orchestration']['group']
  owner  node['openstack']['orchestration']['user']
  mode   00644
  notifies :restart, 'service[heat-api]', :immediately
end

template '/etc/heat/policy.json' do
  source 'policy.json.erb'
  group  node['openstack']['orchestration']['group']
  owner  node['openstack']['orchestration']['user']
  mode   00644
  notifies :restart, 'service[heat-api]', :immediately
end
