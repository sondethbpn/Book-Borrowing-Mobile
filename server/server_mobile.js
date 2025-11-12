const con = require('./db');
const express = require('express');
const bcrypt = require('bcrypt');
const app = express();
const jwt = require('jsonwebtoken');
const multer = require('multer');
const upload = multer({ dest: 'uploads/' });
const bodyParser = require('body-parser');


const SECRET_KEY = 'm0bile2Simple';
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(bodyParser.json());
  
// Configure Cloudinary with API key and secret


// LOGIN ROUTE
app.post('/login', (req, res) => {
    const { identifier, password } = req.body;
    const query = 'SELECT user_id, username, email, password, role FROM users WHERE email = ? OR user_id = ?';

    con.query(query, [identifier, identifier], (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Internal Server Error' });
        }

        if (results.length === 0) {
            console.log('No user found with the provided identifier');
            return res.status(401).json({ error: 'Wrong user ID/email' });
        }

        const user = results[0];

        bcrypt.compare(password, user.password, (err, same) => {
            if (err) {
                console.error(err);
                return res.status(500).json({ error: 'Server error' });
            }

            if (same) {
                // Create a JWT token
                const token = jwt.sign(
                    { user_id: user.user_id, role: user.role }, // Payload
                    SECRET_KEY,
                    { expiresIn: '1h' }
                );
                console.log('JWT generated:', token);
                return res.status(200).json({ token, role: user.role, message: 'Login successful' });
            } else {
                console.log('Password does not match');
                return res.status(401).json({ error: 'Wrong password' });
            }
        });
    });
});

const verifyToken = (req, res, next) => {
    const token = req.headers['authorization']?.split(' ')[1];

    if (!token) {
        return res.status(403).json({ error: 'No token provided' });
    }

    jwt.verify(token, SECRET_KEY, (err, decoded) => {
        if (err) {
            return res.status(401).json({ error: 'Unauthorized' });
        }

        req.user = decoded; // Add decoded user data to request
        next();
    });
};

// Usage
app.get('/protected', verifyToken, (req, res) => {
    res.json({ message: 'This is a protected route', user: req.user });
});

// SHOW TOTAL BORROWED (BROWSE STUDENT)
app.get('/total/borrowed', (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
  
    if (!token) {
      return res.status(401).json({ error: "User not authenticated" });
    }
    jwt.verify(token, SECRET_KEY, (err, decoded) => {
      if (err) {
        console.error("Token verification failed:", err);
        return res.status(403).json({ error: "Invalid or expired token" });
      }
      const userId = decoded.user_id;
      console.log('User ID from token:', userId); 
      const sql = `
        SELECT 
            COUNT(CASE WHEN status = 'approved' THEN 1 END) AS Total_Borrowed,
            COUNT(CASE WHEN status = 'pending' THEN 1 END) AS Total_Pending
        FROM borrows
        WHERE user_id = ?;
      `;
      con.query(sql, [userId], (err, results) => {
        if (err) {
          console.error("SQL Error:", err);
          return res.status(500).send("Database server error");
        }
        if (results.length === 0) {
          return res.status(404).send("No borrows found for this user");
        }
        res.json({
          Total_Borrowed: results[0].Total_Borrowed || 0,
          Total_Pending: results[0].Total_Pending || 0
    });
    });
});
});

// SHOW TOTAL BORROWED (BROWSE LECTURER)
app.get('/total/approved', (req, res) => {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
  
    if (!token) {
      return res.status(401).json({ error: "User not authenticated" });
    }
    jwt.verify(token, SECRET_KEY, (err, decoded) => {
      if (err) {
        console.error("Token verification failed:", err);
        return res.status(403).json({ error: "Invalid or expired token" });
      }
      const userId = decoded.user_id;
      console.log('User ID from token:', userId); 
      const sql = `
        SELECT  
    COUNT(CASE WHEN borrows.status = 'Approved' AND borrows.approver_id = ? THEN 1 END) AS Total_Approved,
    COUNT(CASE WHEN borrows.got_back_by IS NULL AND borrows.return_status = TRUE THEN 1 END) AS Waiting_return,
    COUNT(CASE WHEN borrows.status = 'Pending' THEN 1 END) AS Waiting_approve
FROM 
    books 
INNER JOIN borrows ON books.book_id = borrows.book_id
INNER JOIN users ON borrows.user_id = users.user_id
      `;

      con.query(sql, [userId], (err, results) => {
        if (err) {
          console.error("SQL Error:", err);
          return res.status(500).send("Database server error");
        }
        if (results.length === 0) {
          return res.status(404).send("No borrows found for this user");
        }
        res.json({
            Total_Approved: results[0].Total_Approved || 0,
            Waiting_return: results[0].Waiting_return || 0,
            Waiting_approve: results[0].Waiting_approve || 0
    });
    });
});
});

// SHOW TOTAL BORROWED (BROWSE STAFF)
app.get('/total/details', (req, res) => {
    const sql = `
        SELECT  
    COUNT(CASE WHEN borrows.status = 'Approved' THEN 1 END) AS Total_Approved,
    COUNT(CASE WHEN borrows.got_back_by IS NULL AND borrows.return_status = TRUE THEN 1 END) AS Waiting_return,
    COUNT(CASE WHEN borrows.status = 'Pending' THEN 1 END) AS Waiting_approve
FROM 
    books 
INNER JOIN borrows ON books.book_id = borrows.book_id
INNER JOIN users ON borrows.user_id = users.user_id
      `;

      con.query(sql, (err, results) => {
        if (err) {
          console.error("SQL Error:", err);
          return res.status(500).send("Database server error");
        }
        if (results.length === 0) {
          return res.status(404).send("No borrows found for this user");
        }
        res.json({
            Total_Approved: results[0].Total_Approved || 0,
            Waiting_return: results[0].Waiting_return || 0,
            Waiting_approve: results[0].Waiting_approve || 0
        });
    });
});

// Password generator
app.get('/password/:pass', (req, res) => {
    const password = req.params.pass;
    bcrypt.hash(password, 10, function (err, hash) {
        if (err) {
            return res.status(500).send('Hashing error');
        }
        res.send(hash);
    });
});



// REGISTRATION (SIGN UP)
app.post('/register', (req, res) => {
    const { username, userId, email, password } = req.body;

    // Check for duplicates
    const checkQuery = 'SELECT username, user_id, email, password FROM users WHERE username = ? OR user_id = ? OR email = ?';
    con.query(checkQuery, [username, userId, email], (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).send('Internal Server Error');
        }

        if (results.length > 0) {
            return res.status(400).send('Username, User ID, or Email already exists.');
        }

        bcrypt.hash(password, 10, (err, hash) => {
            if (err) throw err;
            const insertQuery = 'INSERT INTO users (username, user_id, email, password) VALUES (?, ?, ?, ?)';
            con.query(insertQuery, [username, userId, email, hash], (err, result) => {
                if (err) {
                    console.error(err);
                    return res.status(500).send('Internal Server Error');
                } else {
                    console.log('Registration successful!');
                    res.status(200).send('Registration successful!');
                }
            });
        });
    });
});

// SHOW BROWSE ASSETS (BROWSE STUDENT)
app.get("/browses", function (_req, res) {
    const sql = "SELECT * FROM books;";
    con.query(sql, function(err, results) {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        if (results.length === 0) {
            return res.status(404).send("No books found");
        }
        res.json(results); // Return the results
    });
});


// SHOW PROFILE DETAIL (BROWSE STUDENT)
app.get('/profile', function (req, res) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
    if (!token) {
        return res.status(401).json({ error: "User not authenticated" });
    }
    jwt.verify(token, SECRET_KEY, (err, decoded) => {
        if (err) {
            console.error("Token verification failed:", err);
            return res.status(403).json({ error: "Invalid or expired token" });
        }
        const userId = decoded.user_id;
        const sql = `
            SELECT user_id, email, username, role, users.limit 
            FROM users 
            WHERE user_id = ?;
        `;
        con.query(sql, [userId], (err, results) => {
            if (err) {
                console.error("SQL Error:", err);
                return res.status(500).json({ error: "Database server error" });
            }
            if (results.length === 0) {
                return res.status(404).json({ error: "User not found" });
            }
            res.json({
                "user_id": results[0].user_id,
                "email": results[0].email,
                "username": results[0].username,
                "role": results[0].role,
                "limit": results[0].limit
            });
        });
    });
});

// DISPLAY DETAILS OF REQUEST TO BORROWS (STUDENT)
app.get('/reqest/pagestd/:book_id', function (req, res) {
    const bookId = req.params.book_id; // Accessing book_id from URL parameters
    const sql = `SELECT books.book_id, books.book_name, books.image
                 FROM books 
                 WHERE books.book_id = ?;`; // Use bookId in the WHERE clause
    con.query(sql, [bookId], (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        
        if (results.length === 0) {
            return res.status(404).send("No records found for this book");
        }
        res.json(results); 
    });
});


// REQUEST TO BORROWS (STUDENT)
app.post('/request/pagestd/:book_id', function (req, res) {
    const bookId = req.params.book_id;
    const userId = req.body.user_id;
    const returnDate = req.body.return_date;
    
    con.beginTransaction((err) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database transaction error");
        }

        const insertQuery = `
            INSERT INTO borrows (borrow_id, book_id, user_id, borrow_date, return_date, status, approver_id)
            VALUES (NULL, ?, ?, NOW(), ?, 'Pending', NULL)
            ON DUPLICATE KEY UPDATE status = 'Pending';
        `;
        con.query(insertQuery, [bookId, userId, returnDate], (err, results) => {
            if (err) {
                return con.rollback(() => {
                    console.error(err);
                    res.status(500).send("Error inserting borrow record");
                });
            }
            const updateQuery = `
                UPDATE books
                SET status = 'Pending'
                WHERE book_id = ?;
            `;
            con.query(updateQuery, [bookId], (err, updateResults) => {
                if (err) {
                    return con.rollback(() => {
                        console.error(err);
                        res.status(500).send("Error updating books table");
                    });
                }
                const updateUserQuery = `
                    UPDATE users
                    SET users.limit = 'False'
                    WHERE user_id = ?;
                `;
                con.query(updateUserQuery, [userId], (err, userUpdateResults) => {
                    if (err) {
                        return con.rollback(() => {
                            console.error(err);
                            res.status(500).send("Error updating user limit");
                        });
                    }
                    con.commit((err) => {
                        if (err) {
                            return con.rollback(() => {
                                console.error(err);
                                res.status(500).send("Transaction commit error");
                            });
                        }
                        res.json({ message: "Borrow request created successfully", borrowId: results.insertId });
                    });
                });
            });
        });
    });
});

// RETRIEVE DATA (STAFF)
app.get('/edit/admin/:book_id', function (req, res) {
    const bookId = req.params.book_id;
    const sql = `SELECT image, book_name, status FROM books WHERE book_id = ?;`; // Use bookId in the WHERE clause
    con.query(sql, [bookId], (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        if (results.length === 0) {
            return res.status(404).send("No records found for this book");
        }
        res.json(results); 
    });
});

// TO EDIT BOOKS DETAIL (STAFF)
app.put('/edit/admin/:book_id', function (req, res) {
    const bookId = req.params.book_id;
    const { book_name, status } = req.body;
    const sql = `UPDATE books SET book_name = ?, status = ? WHERE book_id = ?;`; 
    con.query(sql, [book_name, status, bookId], (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        if (results.affectedRows === 0) {
            return res.status(404).send("No records found for this book");
        }
        console.log("Book_id:", bookId);
        res.json({ message: "Book updated successfully", results });

    });
});
  

// TO ADD A NEW BOOK (STAFF)
app.post('/adding', upload.single('file'), async (req, res) => {
    const { book_name, status, image } = req.body;
    if (!book_name || !status || !image) {
        return res.status(400).send("All fields are required: book_name, status, image.");
    }
    const sql = 'INSERT INTO books (book_name, status, image) VALUES (?, ?, ?)';
    con.query(sql, [book_name, status, image], (err, result) => {
        if (err) {
            console.error("Database Error:", err);
            return res.status(500).send("Database server error");
        }
        res.status(201).json({ message: "Book added successfully", bookId: result.insertId });
    });
});


// SHOW HISTORY (STAFF)
app.get('/history/staff', function (req, res) {
    const sql = `
        SELECT
    books.book_name,
    books.image,
    borrows.status,
    borrows.approver_id,
    borrows.got_back_by,
    DATE_FORMAT(borrows.return_date, '%Y-%m-%d') AS return_date,
    DATE_FORMAT(borrows.borrow_date, '%Y-%m-%d') AS borrow_date,
    borrower.username AS borrower_name,
    approver.username AS approver_name,
    gotback.username AS got_back_by_name
FROM 
    books 
INNER JOIN borrows ON books.book_id = borrows.book_id
INNER JOIN users AS borrower ON borrows.user_id = borrower.user_id
LEFT JOIN users AS approver ON borrows.approver_id = approver.user_id
LEFT JOIN users AS gotback ON borrows.got_back_by = gotback.user_id
WHERE 
    borrows.status IN ('approved', 'rejected') 
    AND (borrows.got_back_by IS NOT NULL OR borrows.status = 'rejected')
    AND (return_status = 'TRUE' OR borrows.status = 'rejected')
ORDER BY 
    borrows.borrow_date DESC;

    `;

    con.query(sql, (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        
        if (results.length === 0) {
            return res.status(404).send("No records found for this user");
        }
        res.json(results); 
    });
});

// SHOW HISTORY (STUDENT)
app.get('/history/std', function (req, res) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
  
    if (!token) {
      return res.status(401).json({ error: "User not authenticated" });
    }
    jwt.verify(token, SECRET_KEY, (err, decoded) => {
        if (err) {
          console.error("Token verification failed:", err);
          return res.status(403).json({ error: "Invalid or expired token" });
        }
        const userId = decoded.user_id;
    const sql = `
        SELECT
    books.book_name,
    books.image,
    borrows.status,
    borrows.approver_id,
    DATE_FORMAT(borrows.return_date, '%Y-%m-%d') AS return_date,
    DATE_FORMAT(borrows.borrow_date, '%Y-%m-%d') AS borrow_date,
    approver.username AS approver_username
FROM 
    books 
INNER JOIN borrows ON books.book_id = borrows.book_id
INNER JOIN users AS borrower ON borrows.user_id = borrower.user_id
LEFT JOIN users AS approver ON borrows.approver_id = approver.user_id
WHERE 
    borrows.status IN ('approved', 'rejected') 
    AND (borrows.got_back_by IS NOT NULL OR borrows.status = 'rejected')
    AND borrower.user_id = ?
    AND (return_status = 'TRUE' OR borrows.status = 'rejected')
ORDER BY 
    borrows.borrow_date DESC;
    `;

    con.query(sql, [userId], (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        
        if (results.length === 0) {
            return res.status(404).send("No records found for this user");
        }
        res.json(results); 
    });
});
});

// SHOW HISTORY (LECTURDER)
app.get('/history/lecturer', function (req, res) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
  
    if (!token) {
      return res.status(401).json({ error: "User not authenticated" });
    }
    jwt.verify(token, SECRET_KEY, (err, decoded) => {
        if (err) {
          console.error("Token verification failed:", err);
          return res.status(403).json({ error: "Invalid or expired token" });
        }
        const userId = decoded.user_id;
    const sql = `
        SELECT
    books.book_name,
    books.image,
    borrows.status,
    borrows.got_back_by,
    DATE_FORMAT(borrows.return_date, '%Y-%m-%d') AS return_date,
    DATE_FORMAT(borrows.borrow_date, '%Y-%m-%d') AS borrow_date,
    borrower.username AS borrower_name,
    gotback.username AS got_back_by_name
FROM 
    books 
INNER JOIN borrows ON books.book_id = borrows.book_id
INNER JOIN users AS borrower ON borrows.user_id = borrower.user_id
LEFT JOIN users AS gotback ON borrows.got_back_by = gotback.user_id
WHERE 
    borrows.status IN ('approved', 'rejected') 
    AND (borrows.got_back_by IS NOT NULL OR borrows.status = 'rejected')
    AND (return_status = 'TRUE' OR borrows.status = 'rejected')
    AND borrows.approver_id = ?
ORDER BY 
    borrows.borrow_date DESC;
    `;

    con.query(sql, [userId], (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        
        if (results.length === 0) {
            return res.status(404).send("No records found for this user");
        }
        res.json(results); 
    });
});
});

// DISPLAY REQUEST STATUS(STUDENT)
app.get('/display/status', function (req, res) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
  
    if (!token) {
      return res.status(401).json({ error: "User not authenticated" });
    }
    jwt.verify(token, SECRET_KEY, (err, decoded) => {
        if (err) {
          console.error("Token verification failed:", err);
          return res.status(403).json({ error: "Invalid or expired token" });
        }
        const userId = decoded.user_id;
    const sql = `
        SELECT 
        borrows.status,
    borrows.borrow_id, 
    books.book_name, 
    books.image, 
    DATE_FORMAT(borrows.return_date, '%Y-%m-%d') AS return_date, 
    DATE_FORMAT(borrows.borrow_date, '%Y-%m-%d') AS borrow_date
FROM books 
INNER JOIN borrows ON books.book_id = borrows.book_id 
WHERE borrows.user_id = ? 
AND borrows.got_back_by IS NULL
AND borrows.return_status = 'False'
AND borrows.status IN ('approved', 'pending') 
ORDER BY borrows.borrow_date DESC;
    `;
    con.query(sql, [userId], (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        
        if (results.length === 0) {
            return res.status(404).send("No records found for this user");
        }
        res.json(results);
    });
});
});

// TO RETURNING BOOKS (STUDENT)
app.put('/return/assets', function (req, res) {
    const borrowId = req.body.borrow_id;
    const sql = `UPDATE borrows SET return_status = 'True', return_date = CURRENT_DATE() WHERE borrow_id = ?;`;
    
    con.query(sql, [borrowId], (err, result) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        if (result.affectedRows === 0) {
            return res.status(404).send("No record found with this borrow_id");
        }
        res.send("Record updated successfully");
    });
});

// DELETE THE REQUEST (STUDENT)
app.post('/delete/borrow/:borrow_id', function (req, res) {
    const borrowId = req.params.borrow_id;
    con.beginTransaction((err) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database transaction error");
        }
        const selectQuery = `SELECT book_id FROM borrows WHERE borrow_id = ?`;
        con.query(selectQuery, [borrowId], (err, results) => {
            if (err) {
                return con.rollback(() => {
                    console.error(err);
                    res.status(500).send("Error retrieving book_id");
                });
            }
            if (results.length === 0) {
                return con.rollback(() => {
                    res.status(404).send("Borrow record not found");
                });
            }
            const bookId = results[0].book_id;
            const deleteQuery = `DELETE FROM borrows WHERE borrow_id = ?`;
            con.query(deleteQuery, [borrowId], (err, deleteResults) => {
                if (err) {
                    return con.rollback(() => {
                        console.error(err);
                        res.status(500).send("Error deleting borrow record");
                    });
                }
                const updateQuery = `UPDATE books SET status = 'Available' WHERE book_id = ?`;
                con.query(updateQuery, [bookId], (err, updateResults) => {
                    if (err) {
                        return con.rollback(() => {
                            console.error(err);
                            res.status(500).send("Error updating books table");
                        });
                    }
                    con.commit((err) => {
                        if (err) {
                            return con.rollback(() => {
                                console.error(err);
                                res.status(500).send("Transaction commit error");
                            });
                        }

                        res.json({ message: "Borrow record deleted and book status updated successfully" });
                    });
                });
            });
        });
    });
});

// DISPLAY REQUEST TO APPROVE (LECTURER)
app.get('/approves', function (req, res) {
    const sql = `
        SELECT 
            borrows.borrow_id,
            books.book_name,
            books.image, 
            DATE_FORMAT(borrows.return_date, '%Y-%m-%d') AS return_date, 
            DATE_FORMAT(borrows.borrow_date, '%Y-%m-%d') AS borrow_date,
            borrower.username AS borrower_username
        FROM 
            books 
        INNER JOIN borrows ON books.book_id = borrows.book_id
        INNER JOIN users AS borrower ON borrows.user_id = borrower.user_id
        WHERE 
            borrows.status = 'pending'
        ORDER BY 
            borrows.borrow_date DESC;
    `;

    con.query(sql, (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        if (results.length === 0) {
            return res.status(404).send("No pending borrow records found");
        }
        res.json(results); 
    });
});

// TO APPROVE REQUEST (LECTURER)
app.put('/approves/:borrow_id', function (req, res) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
  
    if (!token) {
      return res.status(401).json({ error: "User not authenticated" });
    }
    jwt.verify(token, SECRET_KEY, (err, decoded) => {
        if (err) {
          console.error("Token verification failed:", err);
          return res.status(403).json({ error: "Invalid or expired token" });
        }
        const approver_id = decoded.user_id;
    const borrow_id = req.params.borrow_id;
    if (!borrow_id || !approver_id) {
        return res.status(400).send("borrow_id and approver_id are required");
    }
    const sql = `UPDATE borrows
            JOIN books ON borrows.book_id = books.book_id
            SET borrows.status = 'approved', 
                borrows.approver_id = ?, 
                books.status = 'borrowed'
            WHERE borrows.borrow_id = ?;
            `;

    con.query(sql, [approver_id, borrow_id], (err, result) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        console.log('Approver_id:', approver_id);
        console.log('Borrow_id:', borrow_id);
        if (result.affectedRows === 0) {
            return res.status(404).send("No record found with this borrow_id");
        }
        res.send("THE REQUEST HAS BEEN APPROVED");
    });
    });
});

// TO REJECT REQUEST (LECTURER)
app.put('/rejects/:borrow_id', function (req, res) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];
  
    if (!token) {
      return res.status(401).json({ error: "User not authenticated" });
    }
    jwt.verify(token, SECRET_KEY, (err, decoded) => {
        if (err) {
          console.error("Token verification failed:", err);
          return res.status(403).json({ error: "Invalid or expired token" });
        }
        const approver_id = decoded.user_id;
    const borrow_id = req.params.borrow_id;
    if (!borrow_id || !approver_id) {
        return res.status(400).send("borrow_id and approver_id are required");
    }
    const sql = `UPDATE borrows
            JOIN books ON borrows.book_id = books.book_id
            SET borrows.status = 'rejected', 
                borrows.approver_id = ?, 
                books.status = 'Available'
            WHERE borrows.borrow_id = ?`;

    con.query(sql, [approver_id, borrow_id], (err, result) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        if (result.affectedRows === 0) {
            return res.status(404).send("No record found with this borrow_id");
        }
        res.send("THE REQUEST HAS BEEN REJECTED");
    });
});
});

// DISPLAY DASHBOARD (LECTURER AND STAFF)
app.get('/dashboard', function (req, res) {
    const sql = `
        SELECT 
            COUNT(*) AS Total_Books,
            COUNT(CASE WHEN status = 'available' THEN 1 END) AS Available_Books,
            COUNT(CASE WHEN status = 'borrowed' THEN 1 END) AS Borrowed_Books,
            COUNT(CASE WHEN status = 'disabled' THEN 1 END) AS Disabled_Books
        FROM books;
    `;

    con.query(sql, (err, results) => {
        if (err) {
            console.error(err);
            return res.status(500).send("Database server error");
        }
        if (results.length === 0) {
            return res.status(404).send("No book records found");
        }
        res.json(results[0]); 
    });
});

// DISPLAY RETURN ASSETS (STAFF)
app.get('/gotback', function (req, res) {
    const sql = `
        SELECT borrows.borrow_id, books.book_name, books.image, DATE_FORMAT(borrows.return_date, '%Y-%m-%d') AS return_date, 
            DATE_FORMAT(borrows.borrow_date, '%Y-%m-%d') AS borrow_date, users.username
        FROM books 
        INNER JOIN borrows ON books.book_id = borrows.book_id
        INNER JOIN users ON borrows.user_id = users.user_id
        WHERE borrows.status = 'approved' 
        AND borrows.return_status = 'True'
        AND borrows.got_back_by IS NULL
        ORDER BY 
        borrows.return_date DESC;
    `;
    con.query(sql, (err, results) => {
        if (err) {
            console.error("Database error: ", err);
            return res.status(500).send("Database server error");
        }
        if (results.length === 0) {
            return res.status(404).send("No approved returned book records found");
        }
        res.json(results); // Return all matching records
    });
});


// TO GET THE ASSETS BACK (STAFF)
app.put('/gotback/:borrow_id', function (req, res) {
    const authHeader = req.headers['authorization'];
    const token = authHeader && authHeader.split(' ')[1];

    if (!token) {
        return res.status(401).json({ error: "User not authenticated" });
    }

    jwt.verify(token, SECRET_KEY, (err, decoded) => {
        if (err) {
            console.error("Token verification failed:", err);
            return res.status(403).json({ error: "Invalid or expired token" });
        }
        
        const gotback = decoded.user_id;
        const borrowId = req.params.borrow_id;

        if (!borrowId || !gotback) {
            return res.status(400).send("borrow_id and got_back fields are required");
        }
        con.beginTransaction((err) => {
            if (err) {
                console.error("Transaction start failed:", err);
                return res.status(500).send("Database server error");
            }
            const sqlUpdateBorrow = `UPDATE borrows SET got_back_by = ? WHERE borrow_id = ?`;
            con.query(sqlUpdateBorrow, [gotback, borrowId], (err, result) => {
                if (err) {
                    return con.rollback(() => {
                        console.error("Error updating borrows table:", err);
                        res.status(500).send("Database server error");
                    });
                }
                if (result.affectedRows === 0) {
                    return con.rollback(() => {
                        res.status(404).send("No record found with this borrow_id");
                    });
                }
                const sqlUpdateBookStatus = `
                    UPDATE books 
                    SET status = 'available' 
                    WHERE book_id = (SELECT book_id FROM borrows WHERE borrow_id = ?)
                `;
                con.query(sqlUpdateBookStatus, [borrowId], (err, result) => {
                    if (err) {
                        return con.rollback(() => {
                            console.error("Error updating books table:", err);
                            res.status(500).send("Database server error");
                        });
                    }
                    con.commit((err) => {
                        if (err) {
                            return con.rollback(() => {
                                console.error("Transaction commit failed:", err);
                                res.status(500).send("Database server error");
                            });
                        }
                        res.send("Record updated successfully and book status set to 'Available'");
                    });
                });
            });
        });
    });
});


// ---------- Server starts here ---------
const PORT = 3000;
app.listen(PORT, () => {
    console.log('Server is running at ' + PORT);
});