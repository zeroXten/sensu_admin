#
# Cookbook Name:: sensu_admin
# Recipe:: default
#
# Copyright (C) 2014 
#
# 
#
include_recipe 'apt'
include_recipe 'ruby_build'
include_recipe 'runit'

ruby_build_ruby '1.9.3-p547' do
  prefix_path '/usr/local/'
  environment 'CFLAGS' => '-g -O2'
  action :install
end

gem_package 'bundler' do
  version '1.5.0'
  gem_binary '/usr/local/bin/gem'
  options '--no-ri --no-rdoc'
end

%w[ sqlite sqlite-devel ].each do |pkg|
  package pkg
end

user node.sensu_admin.user do
  manage_home false
end

application 'sensu-admin' do
  owner node.sensu_admin.user
  group node.sensu_admin.group
  path node.sensu_admin.path
  repository node.sensu_admin.repository
  migrate true
  migration_command "bundle exec rake db:migrate && bundle exec rake db:seed"
  rails do
    bundler true
    bundler_without_groups [ 'mysql' ]
    precompile_assets true
    database do
      database 'db/snesu-admin.sqlite3'
      adapter 'sqlite3'
    end
  end
  unicorn do
    worker_processes node.sensu_admin.unicorn.worker_processes
  end
end
