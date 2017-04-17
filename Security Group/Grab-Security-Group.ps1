# MyScript.ps1
param($name=$(throw "You must specify a Security Group"))
"dsget.exe group "CN=STRT-LTM-ADMINS,ou=SecurityGroups,dc=phx,dc=gbl" -member -expand $name"