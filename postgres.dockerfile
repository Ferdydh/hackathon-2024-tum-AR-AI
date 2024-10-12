FROM postgres:14

# Install pgvector
RUN apt-get update && apt-get install -y postgresql-14-pgvector

# Ensure the vector extension is created in the database
RUN echo "CREATE EXTENSION vector;" >> /docker-entrypoint-initdb.d/init_vector.sql
