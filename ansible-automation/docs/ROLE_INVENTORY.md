# Role Inventory

Generated from the consolidated `roles/` tree. Each entry is a role
directory under `roles/` available for use in playbooks.

Total: 350 roles

## OS baseline / config (23)

- `2.3_baseline_replacement`
- `add_rhel_mounts`
- `av_client_rhel`
- `cis_benchmark_check`
- `configure_av_client_rhel`
- `configure_rhel7`
- `configure_rhel8`
- `configure_splunk_forwarder_rhel`
- `configure_winrm`
- `import_baseline_GPOs`
- `install_ipa_rhel6`
- `install_trellix_agent_rhel`
- `join_domain_rhel`
- `link_baseline_IFC_GPOs`
- `link_baseline_dc_GPOs`
- `link_baseline_domain_GPOs`
- `open_rhel_ports`
- `pam_limits`
- `prepare_centos_dev_vm`
- `push_systemd`
- `sysctl`
- `systemd_service`
- `verify-os`

## Networking (18)

- `Network_BackupSwitchConfig`
- `Network_CopyrunstartSwitchConfig`
- `Network_LoadSwitchConfig`
- `Network_UpgradeSwitches`
- `add_consul_to_dns`
- `configure_firewall`
- `configure_search_domain`
- `create_dns`
- `dnsConfig`
- `dns_update`
- `iptables`
- `manage_dnsmasq`
- `network`
- `persist_iptables`
- `reconfigure_network`
- `remove_consul_from_dns`
- `remove_dns`
- `update_iptables`

## Filesystem / storage (17)

- `autofs`
- `configure_autofs`
- `configure_filesystem`
- `configure_volumes`
- `configure_win_disk`
- `configure_win_disk-old`
- `isilon_mount`
- `nas_mount`
- `netapp_mount`
- `nfs`
- `nfs_client_server`
- `nfs_client_windows`
- `partition`
- `shared_home`
- `vm_diskspace`
- `vsphere_disk`
- `vsphere_extend_disk`

## Package management (9)

- `add_yum_repo`
- `configure_yum`
- `gold_data_capture`
- `install_package`
- `install_package_delta`
- `install_package_yum`
- `subscribe_docker`
- `subscription_manager`
- `yum`

## Active Directory / IPA (26)

- `active_directory`
- `active_directory_clean_realm`
- `configure_centrify`
- `configure_dc`
- `configure_ns`
- `create_OUs`
- `create_dc`
- `create_user`
- `disable_accounts`
- `install_ipa`
- `install_ipa_replica`
- `ipa_group`
- `ipa_hbacrules`
- `ipa_hostgroups`
- `ipa_merge_group`
- `ipa_netgroup`
- `ipa_sudocmd`
- `ipa_sudorule`
- `ipaclient`
- `join_domain`
- `join_domain_ssh`
- `join_windows_active_directory`
- `join_windows_active_directory_ou`
- `move_computer_to_ou`
- `remove_known_hosts`
- `sssd_config`

## Antivirus / security (18)

- `av_client_win`
- `certificates`
- `configure_av_client_win`
- `configure_selinux`
- `enable_jsse`
- `enable_tls_win7`
- `export_cert`
- `fetch_certs_jks_files`
- `generate_machine_certs`
- `generate_new_cert`
- `import_certs`
- `import_signed_certs`
- `prepare_additional_cert`
- `push_sudoersd`
- `retrieve_imported_cert`
- `sign_machine_certs`
- `sudoers`
- `update_certificates`

## Splunk / logging (5)

- `configure_splunk_forwarder`
- `configure_splunk_forwarder_windows`
- `configure_splunk_server`
- `restart_splunk_forwarder`
- `restart_splunk_server`

## Container / Docker / EKS (12)

- `configure_eks_admin`
- `configure_eks_registry`
- `configure_eks_ssl`
- `deploy_docker_test_image`
- `docker`
- `download_docker_install_artifacts`
- `download_docker_test_files`
- `download_docker_test_image`
- `install_docker`
- `leave_swarm`
- `start_swarm`
- `uninstall_docker`

## vSphere / VMware (16)

- `affinity_rule`
- `configure_affinity`
- `configure_affinity_OLD`
- `configure_affinity_green`
- `configure_affinity_green_neat`
- `configure_vgpu`
- `configure_vmware_parameters`
- `create_desktop_pool`
- `create_vcenter_folder`
- `create_vds_portgroups`
- `upgrade_vmware_tools`
- `vgpu_profile`
- `vmware_common`
- `vmware_guest`
- `vsphere_vm`
- `vsphere_vm_j`

## Windows-specific (13)

- `configure_windows`
- `configure_windows_old`
- `install_win_features`
- `patch_windows`
- `reboot_windows`
- `reboot_windows_post_patch`
- `remove_autologon`
- `run_win_scripts`
- `windows_cots`
- `wsus_approve_patchset`
- `wsus_check_patches`
- `wsus_import_patches`
- `wsus_report_status`

## GPO / domain ops (5)

- `import_delta_GPOs`
- `import_tenant_GPOs`
- `link_delta_IFC_GPOs`
- `link_delta_dc_GPOs`
- `link_delta_domain_GPOs`

## Install (apps) (39)

- `install_7zip`
- `install_acrobatreader`
- `install_apache`
- `install_consul`
- `install_db`
- `install_filebeat`
- `install_firefox`
- `install_flyway`
- `install_fmw_infrastructure`
- `install_hazelcast_server`
- `install_horizon_agent`
- `install_horizon_client`
- `install_java`
- `install_java8`
- `install_kafka`
- `install_metricbeat`
- `install_neo4j`
- `install_notepad`
- `install_nvidia_driver`
- `install_office`
- `install_office2013`
- `install_office2019`
- `install_oid_ldapadd_plugin`
- `install_prometheus_node_exporter`
- `install_putty`
- `install_python`
- `install_sox`
- `install_sox_4.0.5.1`
- `install_sql_ce`
- `install_sql_express`
- `install_traffic_manager`
- `install_trellix_agent_win`
- `install_vrmc`
- `install_vscode`
- `install_webgate`
- `install_winscp`
- `install_wl_domain_post`
- `install_wl_monitor`
- `install_zookeeper`

## Misc / uncategorized (149)

- `SQLtest`
- `ansible`
- `ansible_modules`
- `apache_verify_config`
- `artifact_staging`
- `binary_installer`
- `build_agent`
- `build_apache`
- `change_apache_config_urls`
- `change_apache_permissions`
- `change_index_urls`
- `change_portal_config_urls`
- `change_rel_index_urls`
- `check_machine_updates`
- `cleanup_ansible`
- `clear_staging`
- `config_wl_settings`
- `configure_adminserver`
- `configure_bp`
- `configure_bp_data`
- `configure_external_ips`
- `configure_firefox`
- `configure_log_rotation`
- `configure_mail_session`
- `configure_nagios`
- `configure_ntp`
- `configure_reposerver`
- `configure_traffic_manager`
- `copy_config`
- `copy_run_start`
- `create_ca_structure`
- `create_linux_service`
- `create_nm_credentials`
- `create_npm_repo`
- `create_plugin_update_list`
- `data_migration`
- `db_enable_archive_log_mode`
- `db_parameters`
- `deployMicroservices`
- `deploy_plugin_updates`
- `deploy_unlimited_jce`
- `deploy_unlimited_jce_legacy`
- `deploy_vm`
- `deregister_with_consul`
- `detect_java`
- `disable_db_remote_login`
- `disable_fips`
- `disable_noexec`
- `discover_gap_machines`
- `download_apache_config`
- `download_apache_source`
- `download_api_documentation`
- `download_artifacts`
- `download_cli`
- `download_clone_artifacts`
- `download_config`
- `download_documentation`
- `download_extra_artifacts`
- `download_images`
- `download_installation_artifacts`
- `download_installation_binaries`
- `download_ldap_plugin_artifacts`
- `download_microservice_dependencies`
- `download_scanning_artifacts`
- `download_traffic_manager_artifacts`
- `dump_neo4j_store`
- `enable_db_remote_login`
- `enable_domain_ssl`
- `enable_fips`
- `enable_noexec`
- `export_data`
- `export_ldap`
- `export_oid_users_ldif`
- `gather_facts`
- `gather_log_entries_for_users`
- `gather_recent_userids`
- `generate_ca_keys`
- `get_with_items`
- `get_with_subelements`
- `gold_data_import_dl_dmp_archive`
- `gold_data_import_stage_dmp`
- `gold_data_import_stage_scripts`
- `group`
- `hosts`
- `identity`
- `import_data`
- `import_ldap`
- `import_module`
- `import_winupdate_module`
- `java`
- `load_classification_data`
- `load_config`
- `load_neo4j_store`
- `manage_legacy_services`
- `notifications`
- `nrpe_client`
- `ntp`
- `patch_wl_10.3.6`
- `ping_hosts`
- `populate_npm_repo`
- `prepare_ansible_slave`
- `prepare_build_slave`
- `provision_linux_agent`
- `push_miscellaneous`
- `push_profiled`
- `query_service_status`
- `reboot_vm`
- `register_with_consul`
- `remove_java8_compiler`
- `resize_vm_host`
- `resolv`
- `resource_pool`
- `restart_authentication_services`
- `restart_hazelcast_service`
- `restart_linux_service_java_app_with_port`
- `restart_portal`
- `restart_vm_processes`
- `set_gc_feature_toggles`
- `setup_winupdate_module`
- `software_factory_deploy`
- `software_factory_prep`
- `software_factory_push`
- `ssh_key`
- `sshd_config`
- `start_atlassian_service`
- `start_consul`
- `start_host_services`
- `start_traffic_manager`
- `start_wl_server`
- `stig_images`
- `stop_atlassian_service`
- `stop_host_services`
- `update_ansible`
- `update_dbdd`
- `update_email_server`
- `update_etc_hosts`
- `update_heap_size`
- `update_identity`
- `update_jta`
- `update_login_banner`
- `update_packages`
- `update_portal_urls`
- `update_properties_files`
- `update_scripts_sha256`
- `update_vm_nics`
- `update_what_system`
- `upgrade-os`
- `upload_artifact`
- `user`
