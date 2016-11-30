from __future__ import print_function

import csv
from datetime import datetime, timedelta
from random import randint, random

def generate_orders(days, now=None):
  # create a batch of orders randomly spaced throughout the batch time period (1 day)
  num_orders = 20 * days
  num_customers = 12
  total_batch_time = 24*60*60 * days  # seconds
  if now is None:
    now = datetime.now()
  created_offsets = sorted((random() * total_batch_time for i in range(num_orders)), reverse=True)
  yield "id,customer_id,units,created_at"
  for id_, created_offset in enumerate(created_offsets, 1):
      customer_id = randint(1, num_customers)
      units = randint(1, 10)
      created_at = now - timedelta(seconds=created_offset)
      created_at = str(created_at) + '+00'  # add timezone
      args = [str(a) for a in [id_, customer_id, units, created_at]]
      yield ','.join(args)

USAGE = 'Usage: generate_orders.py [NUM_DAYS]'

def main(args):
  if not 0 <= len(args) <= 1:
    print(USAGE)
    return -1
  try:
    days = int(args[0])
  except:
    print(USAGE)
    return -1
  for o in generate_orders(days): print(o)
  return 0

if __name__ == "__main__":
  import sys
  sys.exit(main(sys.argv[1:]))
