WITH capacity_check AS (
  SELECT l.capacity - COUNT(r.id)::int AS remaining_slots
  FROM app.lessons l
  LEFT JOIN app.reservations r ON r.lesson_id = l.id
  WHERE l.id = $2
  GROUP BY l.capacity
)
INSERT INTO app.reservations (id, lesson_id, member_id)
SELECT $1, $2, $3
FROM capacity_check
WHERE remaining_slots > 0
RETURNING id;
