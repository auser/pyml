#!/usr/bin/env python

from __future__ import print_function
from jinja2 import Environment, FileSystemLoader

import argparse
import urllib2
import csv
import os
import shutil
import sys
import os.path
import subprocess


UBUNTU_RELEASE_URL = 'http://cloud-images.ubuntu.com/query/trusty/server/released.current.txt'  # NOQA
UBUNTU_RELEASE_FIELD_NAMES = ['version', 'version_type', 'release_status',
                              'date', 'storage', 'arch', 'region', 'id',
                              'kernel', 'unknown_col', 'virtualization_type']


def get_latest_ami(region='us-east-1'):
    response = urllib2.urlopen(UBUNTU_RELEASE_URL).readlines()
    reader = csv.DictReader(response, fieldnames=UBUNTU_RELEASE_FIELD_NAMES,
                            delimiter='\t')

    def ami_filter(ami):
        """Helper function to filter AMIs"""
        return (ami['region'] == region and
                ami['arch'] == 'amd64' and
                ami['storage'] == 'ebs-ssd' and
                ami['virtualization_type'] == 'hvm')

    return [row for row in reader if ami_filter(row)][0]['id']


def get_project_root():
    return os.path.dirname(os.path.abspath(__file__))


def update_ansible_roles(ansible_dir):
    ansible_command = ['ansible-galaxy',
                       'install',
                       '-f',
                       '-r', 'roles.yml',
                       '-p', os.path.join(ansible_dir, 'roles')]
    print(subprocess.check_output(ansible_command, cwd=ansible_dir),
          file=sys.stderr)


def purge_role_examples(ansible_dir):
    ansible_roles_path = os.path.join(ansible_dir, 'roles')

    for role_path in os.listdir(ansible_roles_path):
        examples_path = os.path.join(ansible_roles_path, role_path, 'examples')

        if role_path.startswith('azavea') and os.path.isdir(examples_path):
            shutil.rmtree(examples_path)


def render_packer_config(tmpl, **kwargs):
    packer_dir = os.path.join(get_project_root(), 'packer')
    jinja_env = Environment(loader=FileSystemLoader(packer_dir))

    return jinja_env.get_template('template.tmpl').render(**kwargs)


def main():
    common_parser = argparse.ArgumentParser(add_help=False)

    parser = argparse.ArgumentParser()
    subparsers = parser.add_subparsers(title='Deep Learning Commands')

    create_ami = subparsers.add_parser('packer-config', help='Create Packer '
                                       'configuration',
                                       parents=[common_parser])
    create_ami.add_argument('--instance-type', type=str,
                            choices=['g2.2xlarge', 'g2.8xlarge'],
                            default='g2.2xlarge', help='Packer instance type')
    create_ami.add_argument('--source-ami', type=str, default=get_latest_ami(),
                            help='Base used to create Packer instance')
    create_ami.add_argument('--spot-price', type=str, default="0.50",
                            help='Spot price for Packer instance')
    create_ami.add_argument('--vpc-id', type=str, required=True,
                            help='VPC ID of VPC to launch Packer instance')
    create_ami.add_argument('--subnet-id', type=str, required=True,
                            help='Subnet ID within VPC to launch Packer '
                                 'instance')
    create_ami.add_argument('--ansible-version', type=str, default="2.0.0.2",
                            help='Ansible version used to provision instance')
    create_ami.set_defaults(func=create_ami)

    args = parser.parse_args()

    ansible_dir = os.path.join(get_project_root(), 'ansible')
    update_ansible_roles(ansible_dir)
    purge_role_examples(ansible_dir)

    print(render_packer_config('template.tmpl', **vars(args)))


if __name__ == '__main__':
    main()
