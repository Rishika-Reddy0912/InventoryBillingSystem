CREATE DATABASE IF NOT EXISTS inventory_billing;
USE inventory_billing;

-- Independent Tables
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    sku VARCHAR(20) UNIQUE NOT NULL,
    category VARCHAR(50) NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL CHECK (unit_price >= 0),
    min_stock_level INT DEFAULT 0 CHECK (min_stock_level >= 0),
    INDEX idx_category (category)
) ENGINE=InnoDB;

CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    INDEX idx_supplier_name (name)
) ENGINE=InnoDB;

CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    INDEX idx_customer_name (name)
) ENGINE=InnoDB;

CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) UNIQUE NOT NULL,
    permissions VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role_id INT,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE SET NULL,
    INDEX idx_username (username)
) ENGINE=InnoDB;

CREATE TABLE warehouses (
    warehouse_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    INDEX idx_location (location)
) ENGINE=InnoDB;

-- Dependent Tables
CREATE TABLE stock_movements (
    movement_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    movement_type ENUM('inbound', 'outbound', 'adjustment') NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    movement_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reference VARCHAR(100),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_movement_date (movement_date)
) ENGINE=InnoDB;

CREATE TABLE purchase_orders (
    po_id INT AUTO_INCREMENT PRIMARY KEY,
    supplier_id INT NOT NULL,
    product_id INT NOT NULL,
    order_date DATE NOT NULL,
    quantity_ordered INT NOT NULL CHECK (quantity_ordered > 0),
    quantity_received INT DEFAULT 0 CHECK (quantity_received >= 0),
    status ENUM('pending', 'partial', 'completed') DEFAULT 'pending',
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id) ON DELETE RESTRICT,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    INDEX idx_order_date (order_date)
) ENGINE=InnoDB;

CREATE TABLE sales_orders (
    so_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    order_date DATE NOT NULL,
    quantity_sold INT NOT NULL CHECK (quantity_sold > 0),
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    payment_status ENUM('pending', 'paid', 'overdue') DEFAULT 'pending',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE RESTRICT,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE RESTRICT,
    INDEX idx_order_date (order_date)
) ENGINE=InnoDB;

CREATE TABLE invoices (
    invoice_id INT AUTO_INCREMENT PRIMARY KEY,
    so_id INT NOT NULL,
    invoice_date DATE NOT NULL,
    amount DECIMAL(10, 2) NOT NULL CHECK (amount >= 0),
    payment_date DATE,
    FOREIGN KEY (so_id) REFERENCES sales_orders(so_id) ON DELETE CASCADE,
    INDEX idx_invoice_date (invoice_date)
) ENGINE=InnoDB;

CREATE TABLE product_batches (
    batch_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    batch_number VARCHAR(50) UNIQUE NOT NULL,
    expiry_date DATE,
    quantity INT NOT NULL CHECK (quantity >= 0),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    INDEX idx_expiry_date (expiry_date)
) ENGINE=InnoDB;

CREATE TABLE stock_locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (warehouse_id) REFERENCES warehouses(warehouse_id) ON DELETE CASCADE,
    UNIQUE (product_id, warehouse_id),
    INDEX idx_quantity (quantity)
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    action ENUM('insert', 'update', 'delete') NOT NULL,
    record_id INT NOT NULL,
    changed_by VARCHAR(100) NOT NULL,
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_change_date (change_date)
) ENGINE=InnoDB;