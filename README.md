# How to run

## Backend

To run backend:

1. `pip install -r backend/requirements.txt`
2. `uvicorn backend.server.app:app --reload`

## Frontend (Unity)

To run frontend: `run`

## To use database for the first time:

1. open `localhost:8080`
2. login with username: `admin@admin.com` and password: `admin`
3. Once you’re logged into pgAdmin, you’ll need to configure a connection to your PostgreSQL instance:
   - In pgAdmin, right-click on Servers in the left panel and select Create > Server.
   - In the General tab, give your connection a name (e.g., Hackathon DB).
   - In the Connection tab:
     - Host: db (this is the Docker service name for PostgreSQL as defined in docker-compose.yml).
     - Port: 5432
     - Username: hackathon_user
     - Password: hackathon_password
     - Click Save to create the connection.
4. Now you can manage your PostgreSQL database using pgAdmin's UI.
