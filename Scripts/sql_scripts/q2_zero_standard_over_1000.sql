

-- Finds orders where standard_qty is zero and either gloss_qty or poster_qty is over 1000


SELECT *
FROM orders
WHERE standard_qty = 0 
  AND (gloss_qty > 1000 OR poster_qty > 1000);
