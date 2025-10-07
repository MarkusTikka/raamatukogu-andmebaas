Library Database Seed Generator

See repo sisaldab andmebaasi skeemi (dump.sql) ja skripti, mis täidab skeemi realistlike andmetega, sealhulgas üle 2 000 000 raamatu eksemplari. Järgnevalt on samm-sammuline juhend, kuidas alustada nullist.

Eeldused

Enne alustamist peab olema:

PostgreSQL ≥ 12

Node.js ≥ 20 (või Bun
)

npm või Bun paketihaldur

.env fail juurkataloogis, kus on andmebaasi andmed:

DB_HOST=localhost
DB_PORT=5432
DB_USER=kasutajanimi
DB_PASS=parool
DB_NAME=library

1. Loo andmebaas

Terminalis:

psql -U kasutajanimi -c "CREATE DATABASE library;"


See loob uue PostgreSQL andmebaasi nimega library.

2. Lae skeem
psql -U kasutajanimi -d library -f dump.sql


See loob kõik tabelid, välisvõtmed ja triggerid.

3. Installi vajalikud paketid
npm install
# või Bun kasutades
bun install

4. Käivita seed skript
node seed.js
# või Bun kasutades
bun run seed.js
