#
# Cookbook Name:: beanstalk
# Recipe:: default
#
# Copyright 2011, gotryiton
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

user "beanstalkd" do
  system true
  shell "/bin/false"
end

directory "/var/lib/beanstalkd" do
  owner "beanstalkd"
  group "beanstalkd"
  mode "755"
end

version = node[:beanstalkd][:version]

remote_file "#{Chef::Config[:file_cache_path]}/beanstalkd-#{version}.tar.gz" do
  source node[:beanstalkd][:url]
  checksum node[:beanstalkd][:checksum]
  mode "0644"
  not_if "beanstalkd -v | grep #{version}"
end

cookbook_file "/etc/init.d/beanstalkd" do
  owner 'root'
  group 'root'
  mode "755"
  source "beanstalkd.init"
end

bash "install beanstalkd" do
  cwd "#{Chef::Config[:file_cache_path]}"
  code <<-EOH
  tar zxvf beanstalkd-#{version}.tar.gz
  cd beanstalkd-#{version} && ./configure
  make && make install
  EOH
  not_if "beanstalkd -v | grep #{version}"
end

service "beanstalkd" do
  action [:enable]
  supports [:restart]
end

template "/etc/default/beanstalkd" do
  owner 'root'
  group 'root'
  mode "644"
  source 'beanstalkd_default.erb'
  notifies :restart, "service[beanstalkd]"
end

monit_watch "beanstalkd"
