# KIDL-DB
DB for kidl

Usage in docker-compose:
```SQL 
  flyway:
    image: kidl-db:latest
    container_name: flyway
    command: "migrate"
    environment:
      FLYWAY_USER: ${DB_USER}
      FLYWAY_PASSWORD: ${DB_PASSWORD}
      FLYWAY_URL: jdbc:postgresql://<db-service>:${DB_PORT}/${DB_NAME}

```

The `<db-service>` is a placeholder for the db service in docker file