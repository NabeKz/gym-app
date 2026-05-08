```mermaid
erDiagram
    app_lessons["app.lessons"] {
      uuid id PK
      character_varying(255) name
      character_varying(255) instructor
      timestamp starts_at
      timestamp ends_at
      integer capacity
      integer remaining_slots
      text description
    }
    app_reservations["app.reservations"] {
      uuid id
    }
```
