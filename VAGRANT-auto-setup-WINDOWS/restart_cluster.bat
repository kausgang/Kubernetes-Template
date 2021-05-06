cd .\config
vagrant halt master worker-1
vagrant up --no-provision
vagrant ssh worker-1 -c "sudo mount master:/var/nfs/PV /nfs/PV"