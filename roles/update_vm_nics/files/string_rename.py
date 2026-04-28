#! /usr/bin/env python
"""Script to modify the vsphere virtual hardware for a string"""

from __future__ import print_function
import argparse
import sys
import os
if os.path.isdir(os.getcwd() + '/roles/shared_files/network_update'):
    sys.path.append(os.getcwd() + '/roles/shared_files/network_update')
else:
    sys.path.append(os.path.join(os.getcwd(), '..') + '/roles/shared_files/network_update')

from VSphereUtil import VSphereUtil

def main(args):
    """Main method"""
    
    vsphere_host="10.10.10.224"
	
    vprint = print if args.verbose else lambda *a, **k : None;

    vprint("Connecting to VCenter")
    vsphere = VSphereUtil(vsphere_host)
    vsphere.connect_to_vsphere('gaps\\' + args.vsphere_user, args.vsphere_pswd)

    vprint("Changing the names in vapp {vapp}".format(vapp=args.string_name))

    for vm in vsphere.get_vms(args.string_name):
        vprint(vm.name)
    
        vsphere.update_vm_names(vm, args.cloned_string.lower(), args.string_name.lower())


def get_args():
    """Parses command-line arguments for use in script"""

    parser = argparse.ArgumentParser()
    parser.add_argument('vsphere_user', help="The vsphere user to authenticate as.")
    parser.add_argument('vsphere_pswd', help="The vsphere password to authenticate with")
    parser.add_argument('string_name', type=str.lower,
                        help="The name of the string you wish to modify, e.g. Canary1")
    parser.add_argument('cloned_string', help="The name of the string that was cloned")
    parser.add_argument('-v', '--verbose', action='store_true', help="Enable verbose output")

    return parser.parse_args()


if __name__ == "__main__":
    main(get_args())
