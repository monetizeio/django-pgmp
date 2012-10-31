# -*- mode: ruby -*-
# vi: set ft=ruby :

# === Vagrantfile ---------------------------------------------------------===
# This file is part of django-pgpm. django-pgpm is copyright © 2012, RokuSigma
# Inc. and contributors. See AUTHORS and LICENSE for more details.
#
# django-pgpm is free software: you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# django-pgpm is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License
# for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with django-pgpm. If not, see <http://www.gnu.org/licenses/>.
# ===----------------------------------------------------------------------===

PROJECT_DIR = File.join(File.dirname(__FILE__))

Vagrant::Config.run do |config|
    config.vm.box     = "Ubuntu 12.04 (x86_64)"
    config.vm.box_url = "http://files.vagrantup.com/precise64.box"

    config.vm.define "postgres" do |cfg|
        cfg.vm.forward_port 5432, 5432
        cfg.vm.provision :chef_solo do |chef|
            chef.cookbooks_path = [
                File.join(PROJECT_DIR, 'cookbooks'),
            ]
            chef.add_recipe("apt")
            chef.add_recipe("build-essential")
            chef.add_recipe("postgresql::apt_postgresql_ppa")
            chef.add_recipe("postgresql::server")
            chef.add_recipe("postgresql-pgmp")
            chef.json = {
                :postgresql => {
                    :version => "9.1",
                    :listen_addresses => "*",
                    :hba => [
                        { :method => "trust", :address => "0.0.0.0/0" },
                        { :method => "trust", :address => "::1/0" },
                    ],
                    :password => {
                        :postgres => "password"
                    }
                }
            }
        end
        cfg.vm.provision :shell, :path => 'etc/postgres/init.sh'
    end
end

# ===--------------------------------------------------------------------===
# End of File
# ===--------------------------------------------------------------------===
