$script = <<EOF
apt-get -y update
apt-get -y install build-essential libreadline-dev libssl-dev
cd /vagrant/vendor
make
EOF

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision "shell", inline: $script
end
