const cors = require('cors');
app.use(cors({ origin: 'https://your-netlify-site.netlify.app' })); // Replace with your Netlify URL
// const express = require('express');
const mysql = require('mysql2');
const app = express();

// Middleware to parse JSON
app.use(express.json());

// MySQL Connection
const connection = mysql.createConnection({
  host: '127.0.0.1',
  port: 3307, 
  user: 'root',
  password: 'RishikA@123',
  database: 'inventory_billing'
});

connection.connect((err) => {
  if (err) {
    console.error('MySQL Connection Error:', err);
    process.exit(1);
  }
  console.log('Connected to MySQL Server!');
});

// Login Route
app.post('/login', (req, res) => {
  const { uid } = req.body;
  if (!uid || !/^\d{5}$/.test(uid)) return res.status(400).send('Invalid UID format');
  connection.query('SELECT * FROM Users_ibs WHERE uid = ?', [uid], (err, results) => {
    if (err) {
      console.error(err);
      res.status(500).send('Server error');
    } else if (results.length > 0) {
      const role = parseInt(uid.charAt(0));
      res.json({ message: 'Login successful', role });
    } else {
      res.status(401).send('Invalid UID');
    }
  });
});

// Basic Route
app.get('/', (req, res) => {
  res.send('Inventory Billing System Backend');
});

// Admin CRUD for Users
app.get('/admin/users', (req, res) => {
  connection.query('SELECT * FROM Users_ibs', (err, results) => {
    if (err) throw err;
    res.json(results);
  });
});

app.post('/admin/users', (req, res) => {
  const { uid, name, role } = req.body;
  connection.query('INSERT INTO Users_ibs (uid, name, role) VALUES (?, ?, ?)', [uid, name, role], (err) => {
    if (err) throw err;
    res.send('User added');
  });
});

app.put('/admin/users/:uid', (req, res) => {
  const { uid } = req.params;
  const { name, role } = req.body;
  connection.query('UPDATE Users_ibs SET name = ?, role = ? WHERE uid = ?', [name, role, uid], (err) => {
    if (err) throw err;
    res.send('User updated');
  });
});

app.delete('/admin/users/:uid', (req, res) => {
  const { uid } = req.params;
  connection.query('DELETE FROM Users_ibs WHERE uid = ?', [uid], (err) => {
    if (err) throw err;
    res.send('User deleted');
  });
});

// Admin CRUD for Inventory (products)
app.get('/admin/inventory', (req, res) => {
  connection.query('SELECT * FROM products', (err, results) => {
    if (err) throw err;
    res.json(results);
  });
});

app.post('/admin/inventory', (req, res) => {
  const { name, sku, unit_price, min_stock_level } = req.body;
  connection.query('INSERT INTO products (name, sku, unit_price, min_stock_level) VALUES (?, ?, ?, ?)', [name, sku, unit_price, min_stock_level], (err) => {
    if (err) throw err;
    res.send('Product added');
  });
});

app.put('/admin/promote/:uid', authenticateRole(0), (req, res) => {
  const { uid } = req.params;
  const { newRole } = req.body;
  if (newRole >= 0 && newRole <= 3) {
    connection.query('UPDATE Users_ibs SET role = ? WHERE uid = ?', [newRole, uid], (err) => {
      if (err) throw err;
      res.send('Role updated');
    });
  } else {
    res.status(400).send('Invalid role');
  }
});

// Operator Routes (role 1)
app.get('/operator/inventory', authenticateRole(1), (req, res) => {
  connection.query('SELECT * FROM products ORDER BY name', (err, results) => {
    if (err) throw err;
    res.json(results);
  });
});

app.post('/operator/users', authenticateRole(1), (req, res) => {
  const { uid, name, role } = req.body;
  if (role === 2) {
    connection.query('INSERT INTO Users_ibs (uid, name, role) VALUES (?, ?, ?)', [uid, name, role], (err) => {
      if (err) throw err;
      res.send('Manager added');
    });
  } else {
    res.status(403).send('Can only add managers');
  }
});

app.delete('/operator/users/:uid', authenticateRole(1), (req, res) => {
  const { uid } = req.params;
  connection.query('DELETE FROM Users_ibs WHERE uid = ? AND role = 2', [uid], (err) => {
    if (err) throw err;
    res.send('Manager removed');
  });
});

// Inventory Manager Routes (role 2)
app.put('/inventory/products/:product_id', authenticateRole(2), (req, res) => {
  const { product_id } = req.params;
  const { name, unit_price } = req.body;
  connection.query('UPDATE products SET name = ?, unit_price = ? WHERE product_id = ?', [name, unit_price, product_id], (err) => {
    if (err) throw err;
    res.send('Product updated');
  });
});
app.get('/admin/reports', authenticateRole(0), (req, res) => {
  connection.query('SELECT name, sku, unit_price, min_stock_level FROM products', (err, results) => {
    if (err) throw err;
    res.json({ report: results, generated: new Date().toISOString() });
  });
});
// Start Server
const PORT = 3001;
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
app.get('/inventory/notifications', authenticateRole(2), (req, res) => {
  connection.query('SELECT name, min_stock_level FROM products WHERE min_stock_level < 5', (err, results) => {
    if (err) throw err;
    res.json({ notifications: results.length > 0 ? results : 'No low stock items' });
  });
});
app.put('/user/profile/:uid', (req, res) => {
  const { uid } = req.params;
  const { name } = req.body;
  connection.query('UPDATE users_ibs SET name = ? WHERE uid = ?', [name, uid], (err) => {
    if (err) throw err;
    res.send('Profile updated');
  });
});
app.get('/admin/search', authenticateRole(0), (req, res) => {
  const { query } = req.query;
  connection.query('SELECT * FROM products WHERE name LIKE ?', [`%${query}%`], (err, results) => {
    if (err) throw err;
    res.json(results);
  });
});
const validateInput = (req, res, next) => {
  const { uid, name, role, unit_price, min_stock_level } = req.body;
  if ((req.path.includes('/admin/users') || req.path.includes('/user/profile')) && (!uid || !name || (role !== undefined && (role < 0 || role > 3)))) {
    return res.status(400).send('Invalid user data');
  }
  if (req.path.includes('/admin/inventory') && (!name || !unit_price || min_stock_level < 0)) {
    return res.status(400).send('Invalid product data');
  }
  next();
};

app.use('/admin/users', validateInput);
app.use('/admin/inventory', validateInput);
app.use('/user/profile', validateInput);
const Connection = mysql.createConnection({
  host: process.env.CLEARDB_DATABASE_HOST,
  user: process.env.CLEARDB_DATABASE_USER,
  password: process.env.CLEARDB_DATABASE_PASSWORD,
  database: process.env.CLEARDB_DATABASE_NAME
});
app.get('/admin/backup', authenticateRole(0), (req, res) => {
  connection.query('SELECT * FROM users_ibs UNION ALL SELECT * FROM products', (err, results) => {
    if (err) throw err;
    res.json(results);
  });
});

app.post('/admin/restore', authenticateRole(0), (req, res) => {
  const data = req.body;
  data.forEach(row => {
    if (row.role !== undefined) {
      connection.query('INSERT INTO users_ibs (uid, name, role) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE name = ?, role = ?', [row.uid, row.name, row.role, row.name, row.role]);
    } else {
      connection.query('INSERT INTO products (product_id, name, sku, unit_price, min_stock_level) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE name = ?, unit_price = ?, min_stock_level = ?', [row.product_id, row.name, row.sku, row.unit_price, row.min_stock_level, row.name, row.unit_price, row.min_stock_level]);
    }
  });
  res.send('Restored');
});