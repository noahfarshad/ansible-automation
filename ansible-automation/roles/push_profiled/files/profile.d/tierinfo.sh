# this file is intended to source in to set local variables as
# appropriate
# tlj Nov 9, 2015
# 10/04/2018 - Added F5 load balancer to ldap list - LOB - SA-17115
# 06/19/2020 - Changed from static entries to using Ansible Facts - DER - SA-26602
#		Ansible FACTS defined in enclave-config-net1/defaults/mail.yml
# 06/19/2020 - Added FORMAN_SERVER varible - DER - SA-26602
# 06/22/2020 - Added FACTS for "Other Info" section - DER - SA-26602
# 06/23/2020 - Added if/else statement for SA_ENCLAVE - DER SA-26602
# 06/23/2020 - Added if/else statement for SA_CLASSIFICATION - DER SA-26602
# Classification
#  Valid values are: uncl, sipr, sci1, sci2
    export SA_CLASSIFICATION=uncl

###############################
# Dev/Test/Sandbox Networking
###############################
# Private
export SA_GATEWAY_priv_t=172.16.4.1
export SA_SMTP1_priv_t=172.16.5.47
export SA_SMTP2_priv_t=172.16.6.47
export SA_DNS1_priv_t=172.16.5.47
export SA_DNS2_priv_t=172.16.6.47
export SA_NTP1_priv_t=172.16.5.47
export SA_NTP2_priv_t=172.16.6.47
export SA_SATELLITE_priv_t=172.16.7.19
# Public
export SA_LDAP1_pub_t=ldap://131.7.246.2
export SA_LDAP2_pub_t=ldap://131.7.246.2
export SA_DOMAIN_priv=ess-mgmnt.net

###############################
# Prod Networking
###############################
# Private
export SA_GATEWAY_priv_p=172.16.0.1
export SA_SMTP1_priv_p=172.16.3.127
export SA_SMTP2_priv_p=172.16.3.167
export SA_DNS1_priv_p=172.16.3.127
export SA_DNS2_priv_p=172.16.3.167
export SA_NTP1_priv_p=172.16.3.127
export SA_NTP2_priv_p=172.16.3.167
# Public
export SA_LDAP1_pub_p=ldap://131.7.236.46
export SA_LDAP2_pub_p=ldap://131.7.236.47
export SA_DOMAIN_pub=example.coach

###############################
## Other Info
################################
export SA_MAIL_DOMAIN=us.af.mil
export SA_EMAIL=AFLCMC.HBAWTADS.TADSSA@us.af.mil
export SA_LINUX_EMAIL=AFLCMC.HBAWTADS.TADSSA@us.af.mil
export SA_STG_EMAIL=AFLCMC.HBAWTADS.TADSSA@us.af.mil
export SA_SEC_EMAIL=AFLCMC.HBAWTADS.TADSSA@us.af.mil
export SA_AIX_EMAIL=AFLCMC.HBAWTADS.TADSSA@us.af.mil
export SA_SUN_EMAIL=AFLCMC.HBAWTADS.TADSSA@us.af.mil
export SA_ACN_EMAIL=AFLCMC.HBAWTADS.TADSSA@us.af.mil
export SA_LDAP_BASEDN=ou=people,dc=afwa,dc=af,dc=mil
export FOREMAN_SERVER=https://ess-satellite-02d.${SA_DOMAIN_pub}

#For Dev,Test,or Prod in rhel6/7
    export SA_ENCLAVE=t 
