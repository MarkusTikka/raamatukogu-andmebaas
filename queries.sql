/*
================================================================================
File: queries.sql
Project: Library Database SQL SELECT Queries Exercise
Author: Markus Tikka
Date: 2025-10-07
Branch: main

Description:
This file contains 6 relevant SQL SELECT queries for the library database.
Each query is documented with purpose and expected result.
All queries are designed to provide useful information to librarians, admins,
or library members, following the assignment requirements.
================================================================================
*/

-- 1. Find all currently available books
-- Purpose: Allows the librarian to see which books are available for loan
-- Expected result: List of books with at least 1 copy available
SELECT 
    b.title AS 'Book Title',
    b.isbn AS 'ISBN',
    b.publication_year AS 'Publication Year',
    b.copies_available AS 'Available Copies',
    c.name AS 'Category'
FROM books b
JOIN categories c ON b.category_id = c.id
WHERE b.copies_available > 0
ORDER BY b.title;

-- 2. Find members who currently have books on loan
-- Purpose: Shows which members have active loans
-- Expected result: List of members and their currently borrowed books
SELECT 
    m.first_name AS 'First Name',
    m.last_name AS 'Last Name',
    b.title AS 'Book',
    l.loan_date AS 'Loan Date',
    l.due_date AS 'Due Date'
FROM members m
JOIN loans l ON m.id = l.member_id
JOIN books b ON l.book_id = b.id
WHERE l.status = 'active' AND l.return_date IS NULL
ORDER BY l.due_date;

-- 3. Find the most popular books in the last 12 months
-- Purpose: Identify the most borrowed books in the last year
-- Expected result: Top 10 books with the number of loans
SELECT 
    b.title AS 'Book',
    COUNT(l.id) AS 'Number of Loans in Last Year'
FROM books b
JOIN loans l ON b.id = l.book_id
WHERE l.loan_date >= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
GROUP BY b.id, b.title
HAVING COUNT(l.id) > 5
ORDER BY COUNT(l.id) DESC
LIMIT 10;

-- 4. Find active members who have borrowed more than 10 books
-- Purpose: Identify active members who are frequent readers
-- Expected result: List of members with their total and active loans
SELECT 
    m.id AS 'Member ID',
    m.first_name AS 'First Name',
    m.last_name AS 'Last Name',
    COUNT(l.id) AS 'Total Loans',
    COUNT(CASE WHEN l.status = 'active' THEN 1 END) AS 'Active Loans'
FROM members m
JOIN loans l ON m.id = l.member_id
GROUP BY m.id, m.first_name, m.last_name
HAVING COUNT(l.id) > 10
ORDER BY COUNT(l.id) DESC;

-- 5. Find authors and their books’ categories
-- Purpose: Shows which genres each author writes in
-- Expected result: List of authors with their books and categories
SELECT 
    a.first_name AS 'Author First Name',
    a.last_name AS 'Author Last Name',
    b.title AS 'Book Title',
    c.name AS 'Category'
FROM authors a
JOIN book_authors ba ON a.id = ba.author_id
JOIN books b ON ba.book_id = b.id
JOIN categories c ON b.category_id = c.id
ORDER BY a.last_name, b.title;

-- 6. Find members with overdue loans
-- Purpose: Identify members who have overdue books
-- Expected result: List of members, overdue books, and number of overdue days
SELECT 
    m.first_name AS 'First Name',
    m.last_name AS 'Last Name',
    b.title AS 'Book',
    l.due_date AS 'Due Date',
    DATEDIFF(CURDATE(), l.due_date) AS 'Overdue Days'
FROM members m
JOIN loans l ON m.id = l.member_id
JOIN books b ON l.book_id = b.id
WHERE l.return_date IS NULL 
  AND l.due_date < CURDATE()
ORDER BY DATEDIFF(CURDATE(), l.due_date) DESC;
