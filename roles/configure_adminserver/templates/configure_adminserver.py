
# Setup variable definitions
domain_name = '{{domain_name}}'
domain_name_home = '{{domains_home}}/{{domain_name}}'
wl_home = '{{weblogic_home}}'

# read the domain (offline)
readDomain(domain_name_home)

# Set the audit type
cd('/')    
cmo.setConfigurationAuditType('logaudit')

# Setup the listen address
cd('/Server/' + '{{admin_server}}')
cmo.setListenAddress('{{listen_address}}')

# Setup SSL
create('{{admin_server}}', 'SSL')
cd('SSL/' + '{{admin_server}}')
cmo.setListenPort({{httpsPort}})
cmo.setEnabled(true)

# Update the domain
updateDomain()
closeDomain()

