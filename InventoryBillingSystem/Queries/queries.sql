USE inventory_billing;

SELECT product_id, name, sku, category, unit_price, min_stock_level
FROM products
ORDER BY category, name;

-- Core Feature 2: Stock Movement Tracking - View recent stock movements
SELECT movement_id, p.name, movement_type, quantity, movement_date, reference
FROM stock_movements sm
JOIN products p ON sm.product_id = p.product_id
ORDER BY movement_date DESC
LIMIT 10;

-- Core Feature 3: Supplier Management - List suppliers with contact details
SELECT supplier_id, name, contact_name, phone, email
FROM suppliers
ORDER BY name;

-- Core Feature 4: Customer Management - List customers with contact details
SELECT customer_id, name, contact_name, phone, email
FROM customers
ORDER BY name;

-- Core Feature 5: Purchase Orders - Track pending purchase orders
SELECT po_id, s.name AS supplier_name, p.name AS product_name, quantity_ordered, quantity_received, status, order_date
FROM purchase_orders po
JOIN suppliers s ON po.supplier_id = s.supplier_id
JOIN products p ON po.product_id = p.product_id
WHERE status = 'pending'
ORDER BY order_date;

-- Core Feature 6: Sales Orders & Billing - View unpaid invoices
SELECT i.invoice_id, s.so_id, c.name AS customer_name, i.invoice_date, i.amount, i.payment_date
FROM invoices i
JOIN sales_orders s ON i.so_id = s.so_id
JOIN customers c ON s.customer_id = c.customer_id
WHERE i.payment_date IS NULL
ORDER BY i.invoice_date;

-- Core Feature 7: Inventory Valuation - Calculate total inventory value using FIFO (simplified)\
WITH fifo_stock AS (
    SELECT product_id, SUM(CASE WHEN movement_type = 'inbound' THEN quantity ELSE -quantity END) AS current_stock
    FROM stock_movements
    GROUP BY product_id
    HAVING current_stock > 0
)
SELECT p.name, fs.current_stock, p.unit_price, (fs.current_stock * p.unit_price) AS total_value
FROM products p
JOIN fifo_stock fs ON p.product_id = fs.product_id
ORDER BY total_value DESC;

-- Core Feature 8: Stock Alerts - Identify products below minimum stock level
SELECT p.product_id, p.name, p.min_stock_level, 
       COALESCE(SUM(CASE WHEN sm.movement_type = 'inbound' THEN sm.quantity 
                         WHEN sm.movement_type = 'outbound' THEN -sm.quantity 
                         ELSE 0 END), 0) AS current_stock
FROM products p
LEFT JOIN stock_movements sm ON p.product_id = sm.product_id
GROUP BY p.product_id, p.name, p.min_stock_level
HAVING current_stock < p.min_stock_level
ORDER BY current_stock ASC;

-- Core Feature 9: Audit Logs - View recent changes
SELECT log_id, table_name, action, record_id, changed_by, change_date
FROM audit_logs
ORDER BY change_date DESC
LIMIT 10;

-- Bonus Feature: Monthly Sales Analytics - Total sales per month
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(total_amount) AS total_sales
FROM sales_orders
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- Bonus Feature: Monthly Purchase Analytics - Total purchases per month
SELECT DATE_FORMAT(order_date, '%Y-%m') AS month, SUM(quantity_ordered * unit_price) AS total_purchases
FROM purchase_orders po
JOIN products p ON po.product_id = p.product_id
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month;

-- Bonus Feature: Product Batches - List products with expiry dates approaching (within 30 days)
SELECT p.name, pb.batch_number, pb.expiry_date, pb.quantity
FROM product_batches pb
JOIN products p ON pb.product_id = p.product_id
WHERE expiry_date <= DATE_ADD(CURRENT_DATE, INTERVAL 30 DAY)
  AND expiry_date >= CURRENT_DATE
ORDER BY expiry_date;

-- Bonus Feature: Stock by Warehouse - Current stock per warehouse
SELECT w.name AS warehouse_name, p.name AS product_name, sl.quantity
FROM stock_locations sl
JOIN warehouses w ON sl.warehouse_id = w.warehouse_id
JOIN products p ON sl.product_id = p.product_id
ORDER BY w.name, p.name;

SELECT * FROM products;
SELECT * FROM stock_movements;
UPDATE purchase_orders SET quantity_received = 30 WHERE po_id = 2;
SELECT * FROM stock_locations WHERE product_id = 3;
SELECT * FROM stock_movements WHERE reference = 'PO-2';
SELECT * FROM audit_logs WHERE table_name = 'purchase_orders';

INSERT INTO sales_orders (customer_id, product_id, order_date, quantity_sold, total_amount, payment_status)
VALUES (1, 1, '2025-06-10', 5, 4999.95, 'pending');
SELECT * FROM stock_locations WHERE product_id = 1;
SELECT * FROM stock_movements WHERE reference = 'SO-4';
SELECT * FROM audit_logs WHERE table_name = 'sales_orders';

CALL sp_calculate_fifo_valuation();
CALL sp_calculate_fifo_valuation();
CALL sp_calculate_fifo_valuation();
CALL sp_calculate_fifo_valuation();
CALL sp_generate_monthly_sales_analytics();
CALL sp_generate_monthly_purchase_analytics();
CALL sp_update_stock_alerts();
SELECT * FROM audit_logs WHERE action = 'alert';
SELECT * FROM vw_current_stock_levels;
SELECT * FROM vw_purchase_order_summary;
SELECT * FROM vw_sales_order_summary;
SELECT * FROM vw_inventory_valuation;
SELECT * FROM vw_audit_log_summary;
SELECT * FROM vw_warehouse_stock;
SELECT * FROM vw_product_batch_status;
SELECT * FROM vw_current_stock_levels;
SELECT * FROM vw_inventory_valuation;
CALL sp_calculate_fifo_valuation();
CALL sp_generate_monthly_sales_analytics();
CALL sp_update_stock_alerts();
UPDATE purchase_orders SET quantity_received = 40 WHERE po_id = 2;
INSERT INTO sales_orders (customer_id, product_id, order_date, quantity_sold, total_amount, payment_status)
VALUES (1, 1, '2025-06-20', 5, 4999.95, 'pending');
SELECT * FROM stock_locations;
SELECT * FROM audit_logs;

UPDATE purchase_orders SET quantity_received = 40 WHERE po_id = 2;
INSERT INTO sales_orders (customer_id, product_id, order_date, quantity_sold, total_amount, payment_status)
VALUES (1, 1, '2025-06-20', 5, 4999.95, 'pending');
SELECT * FROM stock_locations;
SELECT * FROM audit_logs;
SELECT * FROM roles; SELECT * FROM users;
SELECT * FROM vw_product_batch_status WHERE expiry_status = 'Expiring Soon';
-- Insert sample data into Product_Batches (Bonus Feature - Batches and Expiry Dates)
INSERT INTO product_batches (product_id, batch_number, expiry_date, quantity) VALUES
(3, 'BATCH003', '2025-09-15', 75),    -- Tablet batch
(4, 'BATCH004', '2027-03-20', 200),   -- Monitor batch
(5, 'BATCH005', '2026-01-10', 150),   -- Keyboard batch
(6, 'BATCH006', '2025-11-25', 80),    -- Mouse batch
(7, 'BATCH007', '2027-07-30', 60),    -- Headphones batch
(8, 'BATCH008', '2026-12-31', 40),    -- Printer batch
(9, 'BATCH009', '2025-10-05', 90),    -- Webcam batch
(10, 'BATCH010', '2028-04-01', 120);  -- Speaker batch
SELECT * FROM vw_product_batch_status WHERE expiry_status ="In Stock";
SELECT * FROM vw_warehouse_stock;

 CALL sp_generate_monthly_sales_analytics();
 CALL sp_generate_monthly_purchase_analytics();