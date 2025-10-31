/* 1. Find all currently available books */
SELECT 
    b.title AS `Book Title`,
    b.isbn AS `ISBN`,
    b.edition AS `Edition`,
    COUNT(bc.id) AS `Available Copies`,
    g.name AS `Genre`
FROM books b
JOIN genres g ON b.genreid = g.id
JOIN bookcopies bc ON b.id = bc.bookid
WHERE bc.status = 'available'
GROUP BY b.id, b.title, b.isbn, b.edition, g.name
ORDER BY b.title;

/* 2. Find users who currently have books on loan */
SELECT 
    u.name AS `Name`,
    b.title AS `Book`,
    t.issuedate AS `Loan Date`,
    t.issuedate + INTERVAL 30 DAY AS `Due Date`
FROM users u
JOIN transactions t ON u.id = t.userid
JOIN bookcopies bc ON t.copyid = bc.id
JOIN books b ON bc.bookid = b.id
WHERE t.status = 'active'
  AND t.returndate IS NULL
ORDER BY t.issuedate;

/* 3. Find the most popular books in the last 12 months */
SELECT 
    b.title AS `Book`,
    COUNT(t.id) AS `Number of Loans in Last Year`
FROM books b
JOIN bookcopies bc ON bc.bookid = b.id
JOIN transactions t ON t.copyid = bc.id
WHERE t.issuedate >= (CURRENT_DATE - INTERVAL 12 MONTH)
GROUP BY b.id, b.title
HAVING COUNT(t.id) > 5
ORDER BY COUNT(t.id) DESC
LIMIT 10;

/* 4. Find active users who have borrowed more than 5 books */
SELECT 
    u.id AS `User ID`,
    u.name AS `Name`,
    COUNT(t.id) AS `Total Loans`,
    COUNT(CASE WHEN t.status = 'active' THEN 1 END) AS `Active Loans`
FROM users u
JOIN transactions t ON u.id = t.userid
GROUP BY u.id, u.name
HAVING COUNT(t.id) > 5
ORDER BY COUNT(t.id) DESC;

/* 5. Find authors and the genres of their books */
SELECT 
    a.first_name AS `Author First Name`,
    a.last_name AS `Author Last Name`,
    b.title AS `Book Title`,
    g.name AS `Genre`
FROM authors a
JOIN books b ON a.id = b.authorid
JOIN genres g ON b.genreid = g.id
ORDER BY a.last_name, b.title;

/* 6. Find users with overdue loans */
SELECT 
    u.name AS `Name`,
    b.title AS `Book`,
    DATEDIFF(CURRENT_DATE, t.issuedate + INTERVAL 30 DAY) AS `Overdue Days`
FROM users u
JOIN transactions t ON u.id = t.userid
JOIN bookcopies bc ON t.copyid = bc.id
JOIN books b ON bc.bookid = b.id
WHERE t.returndate IS NULL
  AND t.issuedate + INTERVAL 30 DAY < CURRENT_DATE
ORDER BY DATEDIFF(CURRENT_DATE, t.issuedate + INTERVAL 30 DAY) DESC;
