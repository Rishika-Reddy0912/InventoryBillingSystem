USE inventory_billing;

-- View 1: Current Stock Levels by Product (Stock Movement Tracking)
CREATE VIEW vw_current_stock_levels AS
SELECT 
    p.product_id,
    p.name,
    p.category,
    COALESCE(SUM(CASE WHEN sm.movement_type = 'inbound' THEN sm.quantity 
                      WHEN sm.movement_type = 'outbound' THEN -sm.quantity 
                      ELSE 0 END), 0) AS current_stock,
    p.min_stock_level,
    CASE 
        WHEN COALESCE(SUM(CASE WHEN sm.movement_type = 'inbound' THEN sm.quantity 
                               WHEN sm.movement_type = 'outbound' THEN -sm.quantity 
                               ELSE 0 END), 0) < p.min_stock_level THEN 'Low'
        ELSE 'Normal'
    END AS stock_status
FROM products p
LEFT JOIN stock_movements sm ON p.product_id = sm.product_id
GROUP BY p.product_id, p.name, p.category, p.min_stock_level;

-- View 2: Purchase Order Summary 
CREATE VIEW vw_purchase_order_summary AS
SELECT 
    po.po_id,
    s.name AS supplier_name,
    p.name AS product_name,
    po.order_date,
    po.quantity_ordered,
    po.quantity_received,
    po.status,
    (po.quantity_ordered - po.quantity_received) AS pending_quantity
FROM purchase_orders po
JOIN suppliers s ON po.supplier_id = s.supplier_id
JOIN products p ON po.product_id = p.product_id;

-- View 3: Sales Order Summary with Customer Details 
CREATE VIEW vw_sales_order_summary AS
SELECT 
    so.so_id,
    c.name AS customer_name,
    p.name AS product_name,
    so.order_date,
    so.quantity_sold,
    so.total_amount,
    so.payment_status,
    i.invoice_date,
    i.payment_date
FROM sales_orders so
JOIN customers c ON so.customer_id = c.customer_id
JOIN products p ON so.product_id = p.product_id
LEFT JOIN invoices i ON so.so_id = i.so_id;

-- View 4: Inventory Valuation Summary 
CREATE VIEW vw_inventory_valuation AS
WITH fifo_stock AS (
    SELECT 
        product_id,
        SUM(CASE WHEN movement_type = 'inbound' THEN quantity 
                 WHEN movement_type = 'outbound' THEN -quantity 
                 ELSE 0 END) AS current_stock
    FROM stock_movements
    GROUP BY product_id
    HAVING current_stock > 0
)
SELECT 
    p.name,
    fs.current_stock,
    p.unit_price,
    (fs.current_stock * p.unit_price) AS total_value
FROM products p
JOIN fifo_stock fs ON p.product_id = fs.product_id;

-- View 5: Audit Log Summary
CREATE VIEW vw_audit_log_summary AS
SELECT 
    log_id,
    table_name,
    action,
    record_id,
    changed_by,
    change_date,
    COUNT(*) OVER (PARTITION BY table_name, action) AS action_count
FROM audit_logs
ORDER BY change_date DESC;

-- View 6: Warehouse Stock Distribution (Multiple Warehouses)
CREATE VIEW vw_warehouse_stock AS
SELECT 
    w.name AS warehouse_name,
    p.name AS product_name,
    sl.quantity,
    p.unit_price,
    (sl.quantity * p.unit_price) AS stock_value
FROM stock_locations sl
JOIN warehouses w ON sl.warehouse_id = w.warehouse_id
JOIN products p ON sl.product_id = p.product_id;

-- View 7: Product Batch Status (Batches and Expiry Dates)
CREATE VIEW vw_product_batch_status AS
SELECT 
    p.name AS product_name,
    pb.batch_number,
    pb.expiry_date,
    pb.quantity,
    DATEDIFF(pb.expiry_date, CURRENT_DATE) AS days_to_expiry,
    CASE 
        WHEN DATEDIFF(pb.expiry_date, CURRENT_DATE) <= 30 THEN 'Expiring Soon'
        WHEN pb.expiry_date < CURRENT_DATE THEN 'Expired'
        ELSE 'In Stock'
    END AS expiry_status
FROM product_batches pb
JOIN products p ON pb.product_id = p.product_id;