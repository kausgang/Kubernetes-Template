cd .\config
vagrant up --no-provision
vagrant ssh worker-1 -c "mount master:/var/nfs/PV /nfs/PV"