#Get arguments from the command line
admin_password = sys.argv[1]
cert_password = sys.argv[2]

#Connect to the adminserver and update machine settings
connect('wl_admin_user', admin_password, 't3://vm4:7201')
edit()
startEdit()
cd('/Machines/vm51/NodeManager/vm51')
cmo.setNMType('SSL')
cd('/Machines/vm52/NodeManager/vm52')
cmo.setNMType('SSL')
cd('/Servers/app_ms6')
cmo.setKeyStores('CustomIdentityAndJavaStandardTrust')
cmo.setCustomIdentityKeyStoreFileName('/opt/identity/identity.jks')
cmo.setCustomIdentityKeyStoreType('JKS')
cmo.setCustomIdentityKeyStorePassPhrase(cert_password)
cd('/Servers/app_ms7')
cmo.setKeyStores('CustomIdentityAndJavaStandardTrust')
cmo.setCustomIdentityKeyStoreFileName('/opt/identity/identity.jks')
cmo.setCustomIdentityKeyStoreType('JKS')
cmo.setCustomIdentityKeyStorePassPhrase(cert_password)
activate()
exit()

