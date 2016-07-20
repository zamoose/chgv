# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2" unless defined? VAGRANTFILE_API_VERSION

dir = Dir.pwd
vagrant_dir = File.expand_path(File.dirname(__FILE__))
vagrant_name = File.basename(dir)
vagrant_version = Vagrant::VERSION.sub(/^v/, '')

# default_installs = vagrant_dir + '/provisioning/default-install.yml'
# custom_installs_dir = vagrant_dir + '/hgv_data/config/sites'

require 'yaml'

domains_array = ['chgv.test', 'admin.chgv.test', 'xhprof.chgv.test', 'mail.chgv.test']

# def domains_from_yml(file)
#     ret = []
#     domains = YAML.load_file(file)
#     domains.each do |key, value|
#         # hhvm_domains are mandatory in user-supplied files
#         value['hhvm_domains'].each do |domain|
#             ret.push(domain)
#             ret.push('cache.' << domain)
#         end
#         # php_domains are optional in the user specified file
#         unless value['php_domains'].nil?
#             value['php_domains'].each do |domain|
#                 ret.push(domain)
#                 ret.push('cache.' << domain)
#             end
#         end
#     end
#
#     return ret
# end

# # Load default domains
# domains_array += domains_from_yml(default_installs)
# # Load user specified domain file
# Dir.glob( custom_installs_dir + "/*.yml").each do |custom_file|
#     domains_array += domains_from_yml(custom_file)
# end
# # Legacy/deprecated file support.  Remove this check in the future.
# Dir.glob( vagrant_dir + '/hgv_data/config/*.yml').each do |custom_file|
#     print "\n*** Custom YML file [ " + custom_file +" ] has been detected ***\n"
#     print "*** DEPRECATED: Please move it to " + custom_installs_dir +"/ ***\n\n"
#     sleep 2
#     domains_array += domains_from_yml(custom_file)
# end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    #config.vm.box = "bento/centos-6.7"
    #config.vm.box = "centos/7"
    config.vm.box = "geerlingguy/centos7"
    config.vm.hostname = "chgv.test"
    config.vm.network "private_network", ip: "192.168.250.20"
    config.vm.network "forwarded_port", guest: 3306, host: 23306
    config.vm.network "forwarded_port", guest: 9001, host: 29001
    # Give vm a name
    config.vm.define vagrant_name do |v|
    end

    config.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", "1024"]
        vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
        vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
        vb.name = vagrant_name
    end

    # config.vm.provider "hyperv" do |hv, override|
    #     # Hyper-V compatible box
    #     override.vm.box = "serveit/centos-7"
    #
    #     # The following configuration options are only available post 1.7.2
    #     if vagrant_version >= "1.7.3"
    #         hv.memory = 1024
    #         hv.vmname = vagrant_name
    #     end
    # end

    # config.vm.provider "parallels" do |vb, override|
    #     override.vm.box = "parallels/centos-7.2"
    #     vb.memory = 1024
    #     vb.name = vagrant_name
    # end

    # config.vm.provider "vmware_fusion" do |vm, override|
    #     override.vm.box = "netsensia/ubuntu-trusty64"
    #     vm.vmx["memsize"] = "1024"
    #     vm.vmx["displayname"] = vagrant_name
    # end
    #
    # config.vm.provider "vmware_workstation" do |vm, override|
    #     override.vm.box = "netsensia/ubuntu-trusty64"
    #     vm.vmx["memsize"] = "1024"
    #     vm.vmx["displayname"] = vagrant_name
    # end

    config.vm.synced_folder "./chgv_data", "/chgv_data", create: "true" #, owner: "nginx", group: "nginx", create: "true"

    config.vm.synced_folders.each do |id, options|
        # Make sure we use Samba for file mounts on Windows
        if ! options[:type] && Vagrant::Util::Platform.windows?
            options[:type] = "smb"
        end
    end

    if defined? VagrantPlugins::Ghost
        config.ghost.hosts = domains_array
    end

    # This allows the git commands to work using host server keys
    config.ssh.forward_agent = true

    # Use a Customfile in the same directory as this Vagrantfile to evaluate (and possibly
    # rewrite) Vagrant configuration lines. Everything in the Customfile will be avaluated
    # as inline Ruby commands, so this is quite possible.
    if File.exists?(File.join(vagrant_dir,'Customfile')) then
      eval(IO.read(File.join(vagrant_dir,'Customfile')), binding)
    end

    # # To avoid stdin/tty issues
    # config.vm.provision "fix-no-tty", type: "shell" do |s|
    #     s.privileged = false
    #     s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
    # end

    # Default/base provisioning
    config.vm.provision "shell" do |s|
        s.path = "bin/init.sh"
        s.keep_color = true
    end

    config.vm.provision "ansible_local" do |ansible|
        ansible.playbook = "provisioning/playbook.yml"
    end

    # # Custom site provisioning
    # config.vm.provision "shell" do |s|
    #     s.path = "bin/custom-sites.sh"
    #     s.keep_color = true
    # end

    # # Vagrant push definition
    # config.push.define "local-exec" do |push|
    #     push.script = "script/push"
    # end
end
