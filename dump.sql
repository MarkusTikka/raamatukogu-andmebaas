-- Raamatukogu andmebaasi skeem

DROP TABLE IF EXISTS loans;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;
DROP TABLE IF EXISTS members;

CREATE TABLE authors (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    genre TEXT NOT NULL,
    author_id INT NOT NULL REFERENCES authors(id)
);

CREATE TABLE members (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    address TEXT NOT NULL,
    joined_at DATE NOT NULL
);

CREATE TABLE loans (
    id BIGSERIAL PRIMARY KEY,
    member_id INT NOT NULL REFERENCES members(id),
    book_id INT NOT NULL REFERENCES books(id),
    loan_date DATE NOT NULL,
    return_date DATE
);
