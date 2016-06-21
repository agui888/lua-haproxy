$script = <<EOF
apt-get -y update
apt-get -y install build-essential git libreadline-dev libssl-dev unzip
cd /vagrant/vendor
make
EOF

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision "shell", inline: $script
  config.vm.network "forwarded_port", guest: 8000, host: 8000, auto_correct:true
  config.vm.network "forwarded_port", guest: 9000, host: 9000, auto_correct:true
end
