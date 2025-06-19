
USE inventory_billing;

-- Insert sample data into Products
INSERT INTO products (name, sku, category, unit_price, min_stock_level) VALUES
('Laptop', 'LAP001', 'Electronics', 999.99, 5),
('Smartphone', 'SPH001', 'Electronics', 499.99, 10),
('Desk Chair', 'CHR001', 'Furniture', 99.99, 15),
('Coffee Maker', 'CMK001', 'Appliances', 79.99, 20);

-- Insert sample data into Suppliers 
INSERT INTO suppliers (name, contact_name, phone, email) VALUES
('Tech Supplies Inc.', 'Alice Smith', '555-0101', 'alice@techsupplies.com'),
('Furniture World', 'Bob Johnson', '555-0102', 'bob@furnworld.com'),
('Home Appliances Co.', 'Clara Lee', '555-0103', 'clara@homeapp.com');

-- Insert sample data into Customers 
INSERT INTO customers (name, contact_name, phone, email) VALUES
('John Doe', 'John Doe', '555-0201', 'john.doe@email.com'),
('Jane Smith', 'Jane Smith', '555-0202', 'jane.smith@email.com'),
('Mike Brown', 'Mike Brown', '555-0203', 'mike.brown@email.com');

-- Insert sample data into Roles (Role-Based Access)
INSERT INTO roles (role_name, permissions) VALUES
('Admin', 'ALL'),
('Manager', 'READ,WRITE'),
('Viewer', 'READ');

-- Insert sample data into Users (Role-Based Access)
INSERT INTO users (username, password_hash, role_id) VALUES
('admin_user', 'hashed_password_1', 1),
('mgr_user', 'hashed_password_2', 2),
('view_user', 'hashed_password_3', 3);

-- Insert sample data into Warehouses (Multiple Warehouses)
INSERT INTO warehouses (name, location) VALUES
('Warehouse A', 'New York'),
('Warehouse B', 'Los Angeles');

-- Insert sample data into Stock_Movements 
INSERT INTO stock_movements (product_id, movement_type, quantity, reference) VALUES
(1, 'inbound', 50, 'PO001'),  -- Laptop
(1, 'outbound', 10, 'SO001'),
(2, 'inbound', 100, 'PO002'), -- Smartphone
(2, 'outbound', 20, 'SO002'),
(3, 'inbound', 30, 'PO003'),  -- Desk Chair
(4, 'inbound', 40, 'PO004');  -- Coffee Maker

-- Insert sample data into Purchase_Orders 
INSERT INTO purchase_orders (supplier_id, product_id, order_date, quantity_ordered, quantity_received, status) VALUES
(1, 1, '2025-06-01', 50, 50, 'completed'),  -- Tech Supplies Inc. - Laptop
(2, 3, '2025-06-02', 30, 20, 'partial'),    -- Furniture World - Desk Chair
(3, 4, '2025-06-03', 40, 40, 'completed');  -- Home Appliances Co. - Coffee Maker

-- Insert sample data into Sales_Orders
INSERT INTO sales_orders (customer_id, product_id, order_date, quantity_sold, total_amount, payment_status) VALUES
(1, 1, '2025-06-05', 10, 9999.90, 'paid'),    -- John Doe - Laptop
(2, 2, '2025-06-06', 20, 9999.80, 'pending'), -- Jane Smith - Smartphone
(3, 3, '2025-06-07', 5, 499.95, 'overdue');   -- Mike Brown - Desk Chair

-- Insert sample data into Invoices 
INSERT INTO invoices (so_id, invoice_date, amount, payment_date) VALUES
(1, '2025-06-05', 9999.90, '2025-06-06'),  -- Paid invoice for John Doe
(2, '2025-06-06', 9999.80, NULL),          -- Pending invoice for Jane Smith
(3, '2025-06-07', 499.95, NULL);           -- Overdue invoice for Mike Brown

-- Insert sample data into Product_Batches (Batches and Expiry Dates)
INSERT INTO product_batches (product_id, batch_number, expiry_date, quantity) VALUES
(1, 'BATCH001', '2026-06-01', 50),  -- Laptop batch
(2, 'BATCH002', '2025-12-01', 100); -- Smartphone batch
-- Insert sample data into Stock_Locations (Bonus Feature - Multiple Warehouses)
INSERT INTO stock_locations (product_id, warehouse_id, quantity) VALUES
(1, 1, 40),  -- Laptop in Warehouse A
(2, 2, 80),  -- Smartphone in Warehouse B
(3, 1, 30),  -- Desk Chair in Warehouse A
(4, 2, 40);  -- Coffee Maker in Warehouse B

-- Insert sample data into Audit_Logs
INSERT INTO audit_logs (table_name, action, record_id, changed_by) VALUES
('products', 'insert', 1, 'admin_user'),
('stock_movements', 'insert', 1, 'mgr_user'),
('sales_orders', 'insert', 1, 'admin_user');