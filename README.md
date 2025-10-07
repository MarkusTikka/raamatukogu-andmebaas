# Library Database Seed Generator – Samm-sammult

See juhend aitab sul alustada nullist ja täita andmebaasi realistlike andmetega, sealhulgas **üle 2 000 000 raamatu eksemplari**, kasutades **Dockerit**. Kõik vajalikud tööriistad ja eeldused on kirjas allpool.

---

## Eeldused

Enne alustamist veendu, et sul on olemas:

1. **Docker ≥ 24**  
   [Paigalda Docker](https://docs.docker.com/get-docker/) vastavalt sinu operatsioonisüsteemile.

2. **Docker Compose ≥ 2.17**  
   Tavaliselt tuleb Docker Compose Dockeriga kaasa. Kontrolli versiooni:
   ```bash
   docker compose version
   ```

3. **Git (soovitatav, aga mitte kohustuslik)**  
   Repo kloonimiseks:
   ```bash
   git clone https://github.com/MarkusTikka/raamatukogu-andmebaas.git
   cd raamatukogu-andmebaas
   ```
   Kui Git puudub, laadi repo ZIP-failina ja paki lahti.

4. **Node.js ≥ 20 või Bun** (ainult seed skripti jaoks, kui ei jooksuta konteineris)  
   [Paigalda Node.js](https://nodejs.org/) või [Bun](https://bun.sh/)

5. **.env fail** juurkataloogis:  
   ```dotenv
   DB_HOST=library-db
   DB_PORT=5432
   DB_USER=kasutajanimi
   DB_PASS=parool
   DB_NAME=library
   ```
   > DB_HOST = Docker Compose teenuse nimi (`library-db`)

---

## 1. Loo Docker Compose fail

`docker-compose.yml` juurkausta:

```yaml
services:
  library-db:
    image: postgres:15
    container_name: library-db
    environment:
      POSTGRES_DB: library
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: passw0rd
    ports:
      - "5433:5432"
    volumes:
      - library-data:/var/lib/postgresql/data

volumes:
  library-data:
```

---

## 2. Käivita PostgreSQL konteiner

```bash
docker compose up -d
```

Kontrolli, kas konteiner töötab:

```bash
docker ps
```

> See loob ja käivitab PostgreSQL andmebaasi konteineris.

---

## 3. Lae skeem andmebaasi

> ⚠️ **Oluline:** Fail `dump.sql` peab olema repo juurkaustas.

Kopeeri `dump.sql` konteinerisse:

```bash
docker cp dump.sql library-db:/dump.sql
```

Täida skeem:

```bash
docker exec -it library-db psql -U $DB_USER -d $DB_NAME -f /dump.sql
```

> See loob kõik tabelid, välisvõtmed ja triggerid.

---

## 4. Installi Node.js paketid

```bash
npm install

```

---

## 5. Käivita seed skript

```bash
npx ts-node seed.ts
# või Bun:
bun run seed.ts
```

> Skript täidab tabelid realistlike andmetega partiisissetustega (`BATCH_SIZE = 5000`).
> Kõik välisvõtmed on õiged, orvukirjeid ei teki. Seed on reprodutseeritav (`faker.seed(123)`).

---

## 6. Kontrolli tulemust

- **`books` tabel**: ≥ 2 000 000 rida
- Teised mitte-lookup tabelid: realistlik arv andmeid
- Andmed näevad ehtsad välja (nimed, e-kirjad, aadressid, kuupäevad)
- Sisestus on partiides, jõudlus optimaalne

---

## Näidis `package.json`

```json
{
  "name": "raamatukogu-andmebaas",
  "version": "1.0.0",
  "description": "Library Database Seed Generator",
  "main": "seed.js",
  "scripts": {
    "start": "node seed.js"
  },
  "dependencies": {
    "pg": "^8.11.0",
    "@faker-js/faker": "^8.0.2",
    "dotenv": "^16.3.1"
  }
}

```

- Selle olemasolul saab seed skripti käivitada lihtsalt:

```bash
npm install
npm run start
# või Bun-ga
bun install
bun run start
```

---

> Kui soovid, võid lisada ka Docker-only versiooni, kus ts-node seed skript jookseb konteineris, nii et Node.js ei pea kohalikus masinas olema.

