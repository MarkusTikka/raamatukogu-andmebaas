Library Database Seed Generator – Samm-sammult

See juhend aitab sul alustada nullist ja täita andmebaasi realistlike andmetega, sealhulgas üle 2 000 000 raamatu eksemplari, kasutades Dockerit. Kõik vajalikud tööriistad ja eeldused on kirjas.

Eeldused

Enne alustamist veendu, et sul on olemas:

Docker ≥ 24

Paigalda Docker
 vastavalt sinu operatsioonisüsteemile.

Docker Compose ≥ 2.17

Tavaliselt tuleb Docker Compose Dockeriga kaasa, kontrolli versiooni:
docker compose version
Git (soovitatav, aga mitte kohustuslik)

Kui Git on olemas, saab repo kloonida:
git clone https://github.com/sinu-kasutaja/library-database-seed.git
cd library-database-seed
https://github.com/MarkusTikka/raamatukogu-andmebaas/blob/main/seed.ts
Kui Git puudub, laadi repo ZIP-failina ja paki lahti.

Node.js ≥ 20 või Bun (ainult seed skripti jaoks, kui ei jooksuta konteineris)

Paigalda Node.js
 või Bun

.env fail juurkataloogis, näiteks:
DB_HOST=library-db
DB_PORT=5432
DB_USER=kasutajanimi
DB_PASS=parool
DB_NAME=library
DB_HOST = Docker Compose teenuse nimi (library-db).

1. Loo Docker Compose fail

Loo fail docker-compose.yml juurkausta:

version: '3.9'

services:
  library-db:
    image: postgres:15
    container_name: library-db
    restart: always
    environment:
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASS}
      POSTGRES_DB: ${DB_NAME}
    ports:
      - "5432:5432"
    volumes:
      - library-data:/var/lib/postgresql/data

volumes:
  library-data:

  2. Käivita PostgreSQL konteiner

   docker compose up -d
   See loob ja käivitab PostgreSQL andmebaasi konteineris.

Kontrolli, kas konteiner töötab:
docker ps

3. Lae skeem andmebaasi

Kopeeri dump.sql konteinerisse:
docker cp dump.sql library-db:/dump.sql

Seejärel täida skeem:
docker exec -it library-db psql -U $DB_USER -d $DB_NAME -f /dump.sql
See loob kõik tabelid, välisvõtmed ja triggerid.

4. Installi Node.js paketid
   Kui Node.js on lokaalset masinas või kasutad Bun-i:
   npm install
# või Bun kasutades
bun install
5. Käivita seed skript
node seed.js
# või Bun kasutades
bun run seed.js
6. Kontrolli tulemust

books tabel: ≥ 2 000 000 rida
Teised mitte-lookup tabelid: realistlik arv andmeid, proportsioonid põhjendatud
Andmed näevad ehtsad välja (nimed, e-kirjad, aadressid, kuupäevad)
Sisestus on partiides, jõudlus optimaalne







