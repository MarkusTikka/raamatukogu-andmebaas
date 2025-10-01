import { Client } from "pg";
import { faker } from "@faker-js/faker";
import * as dotenv from "dotenv";

dotenv.config();

// Reprodutseeritav tulemus
faker.seed(123);

const client = new Client({
  host: process.env.DB_HOST,
  port: Number(process.env.DB_PORT),
  user: process.env.DB_USER,
  password: process.env.DB_PASS,
  database: process.env.DB_NAME,
});

const BATCH_SIZE = 5000;
const LOANS_TARGET = 2_000_000;

async function batchInsert(query: string, values: any[][]) {
  const text = `${query} VALUES ${values
    .map(
      (_, i) =>
        `(${values[i].map((_, j) => `$${i * values[i].length + j + 1}`).join(",")})`
    )
    .join(",")}`;
  const flatValues = values.flat();
  await client.query(text, flatValues);
}

async function main() {
  await client.connect();

  console.log(">>> Eemaldame sekundaarsed indeksid ajutiselt...");
  await client.query(`DROP INDEX IF EXISTS idx_books_author;`);
  await client.query(`DROP INDEX IF EXISTS idx_loans_member;`);
  await client.query(`DROP INDEX IF EXISTS idx_loans_book;`);

  // Autorid
  console.log("Lisame autoreid batchidena...");
  for (let i = 0; i < 5000; i += BATCH_SIZE) {
    const values: any[][] = [];
    for (let j = 0; j < BATCH_SIZE && i + j < 5000; j++) {
      values.push([faker.person.fullName()]);
    }
    await batchInsert("INSERT INTO authors (name)", values);
  }

  // Raamatud
  console.log("Lisame raamatuid batchidena...");
  for (let i = 0; i < 100000; i += BATCH_SIZE) {
    const values: any[][] = [];
    for (let j = 0; j < BATCH_SIZE && i + j < 100000; j++) {
      values.push([
        faker.lorem.words({ min: 2, max: 5 }),
        faker.music.genre(),
        faker.number.int({ min: 1, max: 5000 }),
      ]);
    }
    await batchInsert("INSERT INTO books (title, genre, author_id)", values);
  }

  // Liikmed
  console.log("Lisame liikmeid batchidena...");
  for (let i = 0; i < 50000; i += BATCH_SIZE) {
    const values: any[][] = [];
    for (let j = 0; j < BATCH_SIZE && i + j < 50000; j++) {
      values.push([
        faker.person.fullName(),
        faker.internet.email(),
        faker.location.streetAddress(),
        faker.date.past(),
      ]);
    }
    await batchInsert(
      "INSERT INTO members (name, email, address, joined_at)",
      values
    );
  }

  // Laenud
  console.log("Lisame laenutusi batchidena...");
  let inserted = 0;
  while (inserted < LOANS_TARGET) {
    const values: any[][] = [];
    for (let j = 0; j < BATCH_SIZE; j++) {
      const memberId = faker.number.int({ min: 1, max: 50000 });
      const bookId = faker.number.int({ min: 1, max: 100000 });
      const loanDate = faker.date.past();
      const returnDate =
        Math.random() > 0.5 ? faker.date.soon({ days: 30, refDate: loanDate }) : null;
      values.push([memberId, bookId, loanDate, returnDate]);
    }
    await batchInsert(
      "INSERT INTO loans (member_id, book_id, loan_date, return_date)",
      values
    );
    inserted += BATCH_SIZE;
    if (inserted % 100000 === 0) {
      console.log(`   → ${inserted} laenutust lisatud...`);
    }
  }

  console.log(">>> Taastame sekundaarsed indeksid...");
  await client.query(`CREATE INDEX idx_books_author ON books(author_id);`);
  await client.query(`CREATE INDEX idx_loans_member ON loans(member_id);`);
  await client.query(`CREATE INDEX idx_loans_book ON loans(book_id);`);

  console.log(">>> Valmis!");

  // Kontroll
  for (const table of ["authors", "books", "members", "loans"]) {
    const res = await client.query(`SELECT COUNT(*) FROM ${table}`);
    console.log(`${table}: ${res.rows[0].count} rida`);
  }

  await client.end();
}

main().catch((err) => {
  console.error("Viga:", err);
  client.end();
});
