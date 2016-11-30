#!/usr/bin/env python

"""
Generates data and adds it to the relevant Pachyderm repo

This simulates a script that dumps an external data source (eg live OLTP DB)
"""

from datetime import datetime, timedelta
import itertools
import subprocess
from subprocess import PIPE, Popen

from generate_orders import generate_orders

def commit_orders():
    subprocess.check_output('pachctl create-repo orders'.split())
    now = datetime.now()
    print("Committing orders for day 1...")
    for i in itertools.count():
        current_dt = now + (timedelta(days=1) * i)
        with Popen('pachctl put-file -c orders master orders.csv'.split(), stdin=PIPE, bufsize=-1) as process:
            for order in generate_orders(1, current_dt):
                process.stdin.write(order)
        raw_inpout("Done committing orders for day {}. Press Enter to continue...".format(i))

def commit_customers():
    subprocess.check_output('pachctl create-repo customers'.split())
    subprocess.check_output(
        'pachctl put-file -c customers master customers.csv'.split(),
        stdin=open('data/customers.csv'))

USAGE = 'commit_data.py [delete]'
def main(args):
    if len(args) > 1:
        print USAGE
        return -1
    if len(args) == 1:
        if args[0] == 'delete':
            prompt = 'Are you sure you want to delete repos "customers" and "orders?"'
            if raw_input(prompt).lower() == 'y':
                subprocess.check_output('pachctl delete-repo customers'.split())
                subprocess.check_output('pachctl delete-repo orders'.split())
            else:
                return 0
        else:
            print USAGE
            return -1
    commit_customers()
    commit_orders()
    return 0

if __name__ == '__main__':
    import sys
    sys.exit(main(sys.argv[1:]  ))




# vim: tabstop=8 expandtab shiftwidth=4 softtabstop=4
