# Inventory Billing System

## Overview
The **Inventory Billing System** is a web application built with the MEAN (MongoDB, Express.js, Angular, Node.js) stack, designed to manage inventory, billing, and user roles efficiently. It provides role-based access control for admins, operators, inventory managers, and normal users, streamlining inventory tracking, supplier coordination, and billing processes.

- **Backend**: Node.js with Express.js, MySQL database (local, with plans for ClearDB on Heroku).
- **Frontend**: Angular, hosted on Netlify.
- **Purpose**: A scalable solution for small to medium businesses to manage inventory and billing with secure access levels.

## Features
- **Role-Based Authentication**: Login with a 5-digit UID (first digit defines role: 0 = Admin, 1 = Operator, 2 = Inventory Manager, 3 = Normal User).
- **User Management**: Admins can create, read, update, and delete users; all users can edit their profile.
- **Inventory Management**: Admins add/delete products, inventory managers update details, operators monitor stock.
- **Advanced Features**:
  - Generate inventory reports (Admin).
  - Low stock notifications (< 5 units) for inventory managers.
  - Search products by name (Admin).
  - Submit feedback (all users).
  - Backup and restore data (Admin).
- **Security**: Input validation, planned CORS configuration.
- **Performance**: Lazy loading for Angular, database indexing.
- **Deployment**: Ready for Heroku (backend) and Netlify (frontend).

## Prerequisites
- Node.js and npm
- Angular CLI
- MySQL Server
- Git
- Heroku CLI (for deployment)
- Netlify CLI (for deployment)

## Installation

### Backend Setup
1. Clone the repository:
   ```
   git clone https://github.com/your-username/inventory-billing-system.git
   cd inventory-billing-system
   ```
2. Install dependencies:
   ```
   npm install
   ```
3. Configure MySQL:
   - Create a database named `inventory_billing`.
   - Run the schema from `schema.sql` and sample data from `sample_data.sql` (adjust table name to `users_ibs` if needed).
4. Update `server.js` with your MySQL credentials (or use `.env` with `dotenv`).
5. Start the server:
   ```
   node server.js
   ```

### Frontend Setup
1. Navigate to the frontend folder:
   ```
   cd inventory-frontend
   ```
2. Install dependencies:
   ```
   npm install
   ```
3. Start the development server:
   ```
   npx ng serve
   ```
4. Access at `http://localhost:4200`.

## Usage
- Log in with a UID (e.g., `01234` for Admin, `12345` for Operator).
- Use the dashboard for role-specific actions (e.g., user management for admins, inventory monitoring for operators).
- Test APIs with Postman (e.g., `POST http://localhost:3000/login` with `{ "uid": "01234" }`).

## Deployment
- **Backend**: Deploy to Heroku with `git push heroku main` after configuring ClearDB.
- **Frontend**: Build with `npx ng build --prod` and deploy to Netlify with `netlify deploy --prod`.
- Update `environment.ts` with the Heroku URL post-deployment.

## API Endpoints
- `/login` (POST): Authenticate user.
- `/admin/users` (GET, POST, PUT, DELETE): Manage users (Admin only).
- `/admin/inventory` (GET, POST): Manage products (Admin only).
- `/operator/inventory` (GET): Monitor inventory (Operator only).
- `/inventory/products/:product_id` (PUT): Edit products (Inventory Manager only).
- `/admin/promote/:uid` (PUT): Change user role (Admin only).
- (More endpoints like `/admin/reports`, `/feedback` planned.)

## Contributing
1. Fork the repository.
2. Create a feature branch: `git checkout -b feature-name`.
3. Commit changes: `git commit -m "Add feature-name"`.
4. Push to the branch: `git push origin feature-name`.
5. Open a Pull Request.

## License
[MIT License](LICENSE) - Feel free to modify and distribute.

## Contact
For issues or suggestions, open an issue on GitHub.
