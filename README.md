# InventoryBillingSystem
Project: FIFO Inventory Management System

A MySQL-based inventory management system designed to track stock levels, calculate FIFO-based valuations, and generate reports for efficient inventory control.

Features:

FIFO Valuation Procedure: Calculates inventory value using the First-In, First-Out method via the sp_calculate_fifo_valuation stored procedure.
Stock Tracking: Monitors current stock levels with views like vw_current_stock_levels for real-time insights.
Inventory Valuation Reports: Generates detailed reports on inventory value and trends using vw_inventory_valuation.
CRUD Operations: Supports creating, reading, updating, and deleting inventory records with robust SQL queries.
Data Integrity: Ensures accurate data with primary/foreign key constraints and safe update compliance.
