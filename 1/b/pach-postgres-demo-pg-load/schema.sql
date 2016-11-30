CREATE TYPE pachyderms AS ENUM ('elephant', 'rhino', 'hippo');

CREATE TABLE customers(
  id SERIAL PRIMARY KEY,
  name varchar(127),
  species pachyderms
);

CREATE TABLE orders(
  id SERIAL PRIMARY KEY,
  customer_id integer REFERENCES customers (id),
  units INT,
  created_at TIMESTAMP WITH TIMEZONE DEFAULT (now() at time zone 'utc'),
  shipped_at TIMESTAMP WITH TIMEZONE DEFAULT NULL
);

CREATE TABLE reports(
  id SERIAL PRIMARY KEY,
  day DATE,
  total_units INT
);
