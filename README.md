# Library Database Seed Generator

This repository contains the schema dump and a reproducible seed script for generating realistic library data, including over 2,000,000 book copies.

## Prerequisites

- PostgreSQL ≥ 12
- Node.js ≥ 20 (or Bun)
- npm or Bun for package management
- `.env` file in the root folder with database credentials:


DB_HOST=localhost
DB_PORT=5432
DB_USER=your_username
DB_PASS=your_password
DB_NAME=library

## Database Setup

1. Create the database:

```bash
psql -U your_username -c "CREATE DATABASE library;"
2. Import the schema:

psql -U your_username -d library -f dump.sql
This creates all tables, foreign keys, and triggers.
npm install
# or with Bun
bun install
Run Seed Script
node seed.js
# or with Bun
bun run seed.js
Notes

The seed is reproducible using faker.seed(123).

The script uses batch inserts (BATCH_SIZE = 5000) for performance.

Ensure your PostgreSQL server has sufficient memory and max_allowed_packet configured if using large batches.

Foreign key integrity is guaranteed; there are no orphan records.

All dates are realistic (issue_date, return_date) and formatted correctly for PostgreSQL.
