USE inventory_billing;

-- Procedure 1: Calculate Inventory Valuation using FIFO
DELIMITER //
CREATE PROCEDURE sp_calculate_fifo_valuation()
BEGIN
    DROP TEMPORARY TABLE IF EXISTS fifo_layers;
    CREATE TEMPORARY TABLE fifo_layers (
        product_id INT,
        layer_quantity INT,
        unit_cost DECIMAL(10, 2),
        remaining_quantity INT,
        INDEX idx_product_id (product_id)
    );

    -- Insert initial stock layers from stock movements (inbound only)
    INSERT INTO fifo_layers (product_id, layer_quantity, unit_cost, remaining_quantity)
    SELECT product_id, quantity, (SELECT unit_price FROM products WHERE product_id = sm.product_id) AS unit_cost, quantity
    FROM stock_movements sm
    WHERE movement_type = 'inbound'
    ORDER BY movement_date;

    -- Adjust for outbound movements
    UPDATE fifo_layers fl
    JOIN (
        SELECT product_id, SUM(CASE WHEN movement_type = 'outbound' THEN quantity ELSE 0 END) AS total_outbound
        FROM stock_movements
        GROUP BY product_id
    ) so ON fl.product_id = so.product_id
    SET fl.remaining_quantity = fl.remaining_quantity - so.total_outbound
    WHERE fl.remaining_quantity > 0;

    -- Calculate total valuation
    SELECT p.name, 
           SUM(fl.layer_quantity * fl.unit_cost) AS fifo_value
    FROM fifo_layers fl
    JOIN products p ON fl.product_id = p.product_id
    WHERE fl.remaining_quantity > 0
    GROUP BY p.name;

    DROP TEMPORARY TABLE fifo_layers;
END//
DELIMITER ;

-- Procedure 2: Generate Monthly Sales Analytics 
DELIMITER //
CREATE PROCEDURE sp_generate_monthly_sales_analytics()
BEGIN
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        COUNT(*) AS total_orders,
        SUM(total_amount) AS total_sales
    FROM sales_orders
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
    ORDER BY month;
END//
DELIMITER ;

-- Procedure 3: Generate Monthly Purchase Analytics 
DELIMITER //
CREATE PROCEDURE sp_generate_monthly_purchase_analytics()
BEGIN
    SELECT 
        DATE_FORMAT(order_date, '%Y-%m') AS month,
        COUNT(*) AS total_orders,
        SUM(po.quantity_ordered * p.unit_price) AS total_purchases
    FROM purchase_orders po
    JOIN products p ON po.product_id = p.product_id
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y-%m')
    ORDER BY month;
END//
DELIMITER ;

-- Procedure 4: Update Stock Alert for Low Inventory 
DELIMITER //
CREATE PROCEDURE sp_update_stock_alerts()
BEGIN
    INSERT INTO audit_logs (table_name, action, record_id, changed_by)
    SELECT 'products', 'alert', p.product_id, CONCAT(CURRENT_USER(), ' - Stock Alert')
    FROM products p
    LEFT JOIN stock_locations sl ON p.product_id = sl.product_id
    GROUP BY p.product_id, p.name, p.min_stock_level
    HAVING COALESCE(SUM(sl.quantity), 0) < p.min_stock_level
    ON DUPLICATE KEY UPDATE change_date = CURRENT_TIMESTAMP;
END//
DELIMITER ;