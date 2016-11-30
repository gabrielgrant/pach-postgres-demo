
INSERT into reports (day, total_units) (
  SELECT date_trunc('day', created_at) as day, SUM(units) as total_units
  FROM orders
  GROUP BY date(created_at)
  ORDER BY count(created_at) DESC
);
