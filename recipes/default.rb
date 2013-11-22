#
# Cookbook Name:: scala-sbt
# Recipe:: default
#

include_recipe "java"
include_recipe "yum" if platform?("redhat", "centos", "scientific", "fedora", "arch", "suse")

if (node[:scala_sbt][:barebone]) then
    directory "/opt/sbt/bin/" do 
          owner "root"
          group "root"
          mode 01777
          recursive true
          action :create
    end

    remote_file "/opt/sbt/bin/sbt-launch.jar" do
        source "http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/#{node[:scala_sbt][:sbt_version]}/sbt-launch.jar"
        action :create
        mode 0755
        backup false
    end
    
    remote_file "/opt/sbt/bin/sbt" do
        source "https://raw.github.com/sbt/sbt-launcher-package/full-packaging/src/universal/bin/sbt"
        mode 0755
        action :create
        backup false
    end

    remote_file "/opt/sbt/bin/sbt-launch-lib.bash" do
        source "https://raw.github.com/sbt/sbt-launcher-package/full-packaging/src/universal/bin/sbt-launch-lib.bash"
        action :create
        mode 0755
        backup false
    end
    
    link "/usr/bin/sbt" do
      to "/opt/sbt/bin/sbt"
      action :create
    end

    


else     
    if platform?("redhat", "centos", "scientific", "fedora", "arch", "suse")

        target_file = "#{Chef::Config[:file_cache_path]}/sbt_remote.rpm"

        remote_file target_file do
            source "#{node[:scala_sbt][:repo_url]}/#{node[:scala_sbt][:sbt_version]}/#{node[:scala_sbt][:redhat]}"
            action :create
            backup false
        end

        rpm_package "sbt" do
            source target_file
            action :install
        end

    else

        include_recipe "apt" if platform?("debian","ubuntu")
        target_file = "#{Chef::Config[:file_cache_path]}/sbt_remote.deb"

        remote_file target_file do
            source  "#{node[:scala_sbt][:repo_url]}/#{node[:scala_sbt][:sbt_version]}/#{node[:scala_sbt][:debian]}"
            action :create
            backup false
        end

        package target_file do
            provider Chef::Provider::Package::Dpkg
            action :install
            source target_file
            options "--force-all"
            notifies :run, "execute[apt-get update]", :immediately
        end
    end

    package "sbt"
end
