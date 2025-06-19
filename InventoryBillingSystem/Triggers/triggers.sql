USE inventory_billing;

-- Trigger 1: Update stock_locations on purchase order receipt 
DELIMITER //
CREATE TRIGGER trg_after_purchase_update
AFTER UPDATE ON purchase_orders
FOR EACH ROW
BEGIN
    IF NEW.quantity_received > OLD.quantity_received THEN
        INSERT INTO stock_movements (product_id, movement_type, quantity, reference)
        VALUES (NEW.product_id, 'inbound', NEW.quantity_received - OLD.quantity_received, CONCAT('PO-', NEW.po_id));
        
        INSERT INTO audit_logs (table_name, action, record_id, changed_by)
        VALUES ('purchase_orders', 'update', NEW.po_id, CURRENT_USER());
        
        UPDATE stock_locations sl
        SET sl.quantity = sl.quantity + (NEW.quantity_received - OLD.quantity_received)
        WHERE sl.product_id = NEW.product_id
        AND sl.warehouse_id = (SELECT warehouse_id FROM warehouses LIMIT 1); -- Default to first warehouse; adjust logic if needed
    END IF;
END//
DELIMITER ;

-- Trigger 2: Update stock_locations on sales order creation 
DELIMITER //
CREATE TRIGGER trg_after_sales_insert
AFTER INSERT ON sales_orders
FOR EACH ROW
BEGIN
    INSERT INTO stock_movements (product_id, movement_type, quantity, reference)
    VALUES (NEW.product_id, 'outbound', NEW.quantity_sold, CONCAT('SO-', NEW.so_id));
    
    INSERT INTO audit_logs (table_name, action, record_id, changed_by)
    VALUES ('sales_orders', 'insert', NEW.so_id, CURRENT_USER());
    
    UPDATE stock_locations sl
    SET sl.quantity = sl.quantity - NEW.quantity_sold
    WHERE sl.product_id = NEW.product_id
    AND sl.warehouse_id = (SELECT warehouse_id FROM warehouses LIMIT 1); -- Default to first warehouse; adjust logic if needed
    
    -- Check stock level and update min_stock_level if violated
    IF (SELECT quantity FROM stock_locations WHERE product_id = NEW.product_id) < 
        (SELECT min_stock_level FROM products WHERE product_id = NEW.product_id) THEN
        INSERT INTO audit_logs (table_name, action, record_id, changed_by)
        VALUES ('products', 'alert', NEW.product_id, CONCAT(CURRENT_USER(), ' - Stock Alert'));
    END IF;
END//
DELIMITER ;

-- Trigger 3: Log updates to products table (Audit Logs)
DELIMITER //
CREATE TRIGGER trg_after_products_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, action, record_id, changed_by)
    VALUES ('products', 'update', NEW.product_id, CURRENT_USER());
END//
DELIMITER ;

-- Trigger 4: Log deletes from products table (Audit Logs)
DELIMITER //
CREATE TRIGGER trg_after_products_delete
AFTER DELETE ON products
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, action, record_id, changed_by)
    VALUES ('products', 'delete', OLD.product_id, CURRENT_USER());
END//
DELIMITER ;

-- Trigger 5: Log inserts into sales_orders table (Audit Logs)
DELIMITER //
CREATE TRIGGER trg_after_sales_orders_insert
AFTER INSERT ON sales_orders
FOR EACH ROW
BEGIN
    INSERT INTO audit_logs (table_name, action, record_id, changed_by)
    VALUES ('sales_orders', 'insert', NEW.so_id, CURRENT_USER());
END//
DELIMITER ;