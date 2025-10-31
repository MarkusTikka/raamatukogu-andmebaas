/* 
  queries.sql - Rewritten for the actual project schema (PostgreSQL)
  Tables:
    - authors (assumed columns: id, first_name, last_name, etc.)
    - genres (id, name, ...)
    - books (id, isbn, title, authorid, genreid, edition)
    - users (id, name, email, password, role)
    - bookcopies (id, bookid, barcode, status)
    - transactions (id, userid, copyid, issuedate, returndate, status)
*/

/* 1. Find all currently available books 
   Purpose: List books that have at least one available copy.
   Expected result: Books with available copies, grouped by title and genre.
   Note: "Available" copies are taken as those in bookcopies with status = 'available'
*/
SELECT 
    b.title AS "Book Title",
    b.isbn AS "ISBN",
    b.edition AS "Edition",
    COUNT(bc.id) AS "Available Copies",
    g.name AS "Genre"
FROM books b
JOIN genres g ON b.genreid = g.id
JOIN bookcopies bc ON b.id = bc.bookid
WHERE bc.status = 'available'
GROUP BY b.id, b.title, b.isbn, b.edition, g.name
ORDER BY b.title;

/* 2. Find users who currently have books on loan 
   Purpose: Show users with active loan transactions.
   Expected result: List of users, borrowed books, loan dates, and due dates.
   Note: We assume users table replaces members, and transactions replaces loans.
         Books are linked via bookcopies. Due date is calculated as issuedate + 30 days.
*/
SELECT 
    u.name AS "Name",
    b.title AS "Book",
    t.issuedate AS "Loan Date",
    (t.issuedate + INTERVAL '30 days')::date AS "Due Date"
FROM users u
JOIN transactions t ON u.id = t.userid
JOIN bookcopies bc ON t.copyid = bc.id
JOIN books b ON bc.bookid = b.id
WHERE t.status = 'active'
  AND t.returndate IS NULL
ORDER BY t.issuedate;

/* 3. Find the most popular books in the last 12 months 
   Purpose: Identify top 10 books (with more than 5 loans) based on loan count within the last year.
   Expected result: Top 10 most borrowed books with loan counts.
   Note: Loan date is taken as transactions.issuedate.
*/
SELECT 
    b.title AS "Book",
    COUNT(t.id) AS "Number of Loans in Last Year"
FROM books b
JOIN bookcopies bc ON bc.bookid = b.id
JOIN transactions t ON t.copyid = bc.id
WHERE t.issuedate >= (CURRENT_DATE - INTERVAL '12 months')
GROUP BY b.id, b.title
HAVING COUNT(t.id) > 5
ORDER BY COUNT(t.id) DESC
LIMIT 10;

/* 4. Find active users who have borrowed more than 5 books 
   Purpose: Identify frequent borrowers.
   Expected result: List of users with their total and active loan counts.
   Note: Total loans and active (status = 'active') loans are computed from transactions.
*/
SELECT 
    u.id AS "User ID",
    u.name AS "Name",
    COUNT(t.id) AS "Total Loans",
    COUNT(CASE WHEN t.status = 'active' THEN 1 END) AS "Active Loans"
FROM users u
JOIN transactions t ON u.id = t.userid
GROUP BY u.id, u.name
HAVING COUNT(t.id) > 5
ORDER BY COUNT(t.id) DESC;

/* 5. Find authors and the genres of their books 
   Purpose: List each author with their book titles and corresponding genres.
   Expected result: Authors listed with their books and genres, sorted by author last name.
   Note: books.authorid directly connects to authors.id and books.genreid to genres.id.
*/
SELECT 
    a.first_name AS "Author First Name",
    a.last_name AS "Author Last Name",
    b.title AS "Book Title",
    g.name AS "Genre"
FROM authors a
JOIN books b ON a.id = b.authorid
JOIN genres g ON b.genreid = g.id
ORDER BY a.last_name, b.title;

/* 6. Find users with overdue loans 
   Purpose: Identify users with loans overdue based on a 30-day loan period.
   Expected result: Users with overdue books, sorted by number of overdue days (highest first).
   Note: Due date is assumed as (issuedate + 30 days). A loan is overdue if:
         - t.returndate IS NULL
         - (t.issuedate + INTERVAL '30 days') is before CURRENT_DATE.
         Overdue days is calculated as the difference between CURRENT_DATE and the due date.
*/
SELECT 
    u.name AS "Name",
    b.title AS "Book",
    (CURRENT_DATE - (t.issuedate + INTERVAL '30 days')::date)::INTEGER AS "Overdue Days"
FROM users u
JOIN transactions t ON u.id = t.userid
JOIN bookcopies bc ON t.copyid = bc.id
JOIN books b ON bc.bookid = b.id
WHERE t.returndate IS NULL
  AND (t.issuedate + INTERVAL '30 days')::date < CURRENT_DATE
ORDER BY (CURRENT_DATE - (t.issuedate + INTERVAL '30 days')::date)::INTEGER DESC;
