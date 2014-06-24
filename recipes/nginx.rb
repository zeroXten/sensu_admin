include_recipe 'nginx::default'

%w[ default.conf  ssl.conf  virtual.conf ].each do |f|
  file "#{node.nginx.dir}/conf.d/#{f}" do
    action :delete
  end
end

template "#{node.nginx.dir}/sites-available/sensu-admin" do
  owner "root"
  group "root"
  mode 0644
  notifies :restart, "service[nginx]"
end

nginx_site 'sensu-admin' do
  enable true
end
