from __future__ import print_function

import csv
from datetime import datetime, timedelta
from random import randint, random

# create a batch of orders randomly spaced throughout the batch time period (1h)
num_orders = 10
num_customers = 12
total_batch_time = 60*60  # seconds
now = datetime.now()
created_offsets = sorted(random() * total_batch_time for i in range(num_orders))
for id_, created_offset in enumerate(created_offsets, 1):
    customer_id = randint(1, num_customers)
    units = randint(1, 10)
    created_at = now + timedelta(seconds=created_offset)
    created_at = str(created_at) + '+00'  # add timezone
    args = [str(a) for a in [id_, customer_id, units, created_at]]
    print(','.join(args))
 
