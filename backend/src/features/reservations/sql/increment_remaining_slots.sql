UPDATE app.lessons
SET remaining_slots = remaining_slots + 1
WHERE id = $1;
