WITH locked AS (
  SELECT id FROM app.lessons WHERE id = $1 FOR UPDATE
)
SELECT
  l.capacity,
  COUNT(r.id)::int AS reserved_count
FROM app.lessons l
LEFT JOIN app.reservations r ON r.lesson_id = l.id
JOIN locked ON locked.id = l.id
GROUP BY l.capacity;
