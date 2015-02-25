#
# Cookbook Name:: thumbor
# Recipe:: experimental
#
# Copyright 2013, Enrico Baioni <enrico.baioni@zanui.com.au>
# Copyright 2013, Zanui <engineering@zanui.com.au>
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

apt_repository 'thumbor' do
  uri 'http://ppa.launchpad.net/thumbor/ppa/ubuntu'
  distribution 'saucy'
  components ['main']
  keyserver 'keyserver.ubuntu.com'
  key 'CBEC8F27'
  deb_src true
end

apt_repository 'multiverse' do
  uri 'http://us.archive.ubuntu.com/ubuntu/'
  distribution node['lsb']['codename']
  components %w(main multiverse)
  deb_src true
end

required_packages = %w(
  git
  redis-server
  webp
  libwebp-dev
  thumbor
)

required_packages.each do |pkg|
  package pkg
end

service 'redis-server' do
  supports :restart => true, :start => true, :stop => true, :reload => true
  action [:enable, :start]
end

template '/etc/init/thumbor.conf' do
  source 'thumbor.ubuntu.upstart.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/init/thumbor-worker.conf' do
  source 'thumbor.worker.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

template '/etc/default/thumbor' do
  source 'thumbor.default.erb'
  owner 'root'
  group 'root'
  mode '0644'
#  notifies :restart, 'service[thumbor]'
  variables({
              :instances => node['thumbor']['processes'],
              :base_port => node['thumbor']['base_port']
            })
end

# template '/etc/init.d/thumbor' do
#   source 'thumbor.init.erb'
#   owner  'root'
#   group  'root'
#   mode   '0755'
# end

template '/etc/thumbor.conf' do
  source 'thumbor.conf.default.erb'
  owner 'root'
  group 'root'
  mode '0644'
#  notifies :restart, 'service[thumbor]'
  variables({
              :options    => node['thumbor']['options']
            })
end

file '/etc/thumbor.key' do
  content node['thumbor']['key']
  owner 'root'
  group 'root'
  mode '0644'
#  notifies :restart, 'service[thumbor]'
end

#service 'thumbor' do
#  provider Chef::Provider::Service::Upstart
#  supports :restart => true, :start => true, :stop => true, :reload => true
#  action [:enable, :start]
#end
