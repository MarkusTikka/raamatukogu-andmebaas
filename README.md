# Raamatukogu andmebaas

## Eesmärk
Luua raamatukogu andmebaas realistlike andmetega, kus **loans** tabelis on vähemalt 2 000 000 rida.

## Eeldused
- PostgreSQL (testitud v15)
- Bun (testitud v1.1+)
- Node moodulid: `pg`, `@faker-js/faker`, `dotenv`
- `.env` fail järgmiste väärtustega:
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASS=postgres
DB_NAME=librarydb
1. Loo andmebaas
createdb librarydb
2. Lae skeem sisse
psql -U postgres -d librarydb -f dump.sql
3. Paigalda vajalikud moodulid
bun install pg @faker-js/faker dotenv
4. Käivita seemneskript
bun run seed.ts
5. Kontrolli ridade arvu
SELECT COUNT(*) FROM authors;
SELECT COUNT(*) FROM books;
SELECT COUNT(*) FROM members;
SELECT COUNT(*) FROM loans;
