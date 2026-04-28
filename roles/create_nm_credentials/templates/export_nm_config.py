#Connect to the nodemanager and store the config files
nmConnect('{{nodemanager_username}}', '{{wl_gc2_admin_password}}', '{{inventory_hostname}}', {{nm_listen_port}}, '{{domain_name}}', '{{domain_home}}', '{{nm_type}}')
storeUserConfig('{{gc2_config_path}}/{{config_key}}', '{{gc2_config_path}}/{{nm_key}}', '{{store_credentials}}')
exit()
