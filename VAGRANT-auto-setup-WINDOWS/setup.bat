cd .\config
vagrant destroy -f master worker-1
vagrant up

md ..\connection-setting
copy .\.vagrant\machines\master\virtualbox\private_key ..\connection-setting\master_private_key.ppk
copy .vagrant\machines\worker-1\virtualbox\private_key ..\connection-setting\worker-1_private_key.ppk
copy JOIN_NETWORK.sh ..\connection-setting\JOIN_NETWORK.sh
copy config ..\connection-setting\config

del JOIN_NETWORK.sh
del config