# Digimaks Database

This repository contains the database schema and migrations for the Digimaks project. It uses Evolve for database version control and is designed for PostgreSQL.

## Project Structure

- `code/`: Contains repeatable SQL migrations for various schemas:
  - `attestation_provider/`: Migrations for attestation provider functionality.
  - `audit/`: Audit-related migrations.
  - `session/`: Session management migrations.
  - `wallet_provider/`: Wallet provider migrations.
- `testing/`: Scripts for database initialization, linting, and testing.
  - `db-init.sh`: Initializes the database.
  - `lint-pgSQL.sql`: Linting script for PostgreSQL.
  - `wait-for-postgres.sh`: Waits for PostgreSQL to be ready.
- `unused_procedures/`: Deprecated or unused stored procedures.
- `versions/`: Versioned migrations starting from version 1.0.0.

## Prerequisites

- PostgreSQL database server
- Evolve plugin for running migrations
- Bash shell for running scripts

## Setup

1. Ensure PostgreSQL is running and accessible.
2. Clone the repository and navigate to the database directory.
3. Run the initialization script:
   ```bash
   ./testing/db-init.sh
   ```
4. Apply migrations using Evolve

## Testing

- Use `lint-pgSQL.sql` to check for SQL linting issues.
- Run tests as needed with the provided scripts.


