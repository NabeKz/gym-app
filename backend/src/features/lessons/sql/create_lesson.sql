INSERT INTO app.lessons
  (id, name, instructor, starts_at, ends_at, capacity, remaining_slots, description)
VALUES
  ($1, $2, $3, $4, $5, $6, $7, $8)
RETURNING
  id, name, instructor, starts_at, ends_at, capacity, remaining_slots, description
