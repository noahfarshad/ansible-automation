Role Name
=========

autofs
this role is to install autofs as well as requirements for sshfs with autofs

Requirements
------------

Packages that need to be installed
autofs (part of starndard redhat repo)
fuse (not in redhat repo found at "https://afw-artifactory-t.example.coach/artifactory/thirdparty/fuse/rhel7/fuse-2.9.2-11.el7.x86_64.rpm")
fuse-libs (not in redhat repo found at "https://afw-artifactory-t.example.coach/artifactory/thirdparty/fuse/rhel7/fuse-2.9.2-11.el7.x86_64.rpm")
fuse-sshfs (not in redhat repo found at "https://afw-artifactory-t.example.coach/artifactory/thirdparty/fuse/rhel7/fuse-2.9.2-11.el7.x86_64.rpm")

Role Variables
--------------
should be in group variables following "autofs_lines"
- name: <name of file that should be added to roles/autofs/files to set autofs setting>
  direcotry: <the directory that will be automounted with autofs>
  send: <a command used for sshfs to add to add a line to roots know_hosts file so that sshfs can be mounted ex "scp -o StrictHostKeyChecking=no -i /home/vwadmin/.ssh/id_rsa vwadmin@ess-nas-03p:/home/vwadmin/.ssh/id_rsa /tmp/temp">
  clean: <a command to cleanup scp file created when creating the known_hosts entry ex "rm -f /tmp/temp">


Dependencies
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

Example Playbook
----------------

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

    - hosts: servers
      roles:
         - { role: username.rolename, x: 42 }

License
-------

BSD

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
