// MongoDB Initialization Script
// This script runs when MongoDB container is first created

// Switch to the bhumi-interior database
db = db.getSiblingDB('bhumi-interior');

// Create collections
db.createCollection('users');
db.createCollection('galleries');

// Create indexes for better performance
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ createdAt: -1 });
db.galleries.createIndex({ createdAt: -1 });

// Create default admin user (change password in production!)
const bcrypt = require('bcrypt');
const defaultPassword = 'admin123'; // Change this!

db.users.insertOne({
  name: 'Admin User',
  email: 'admin@bhumiinteriorsolution.in',
  phone: '+91 92281 04285',
  password: '$2b$10$rQZ5Q9h5h5h5h5h5h5h5h5', // This is a placeholder, will be created properly via register endpoint
  role: 'admin',
  createdAt: new Date(),
  updatedAt: new Date()
});

print('✅ Database initialized successfully');
print('📧 Default admin email: admin@bhumiinteriorsolution.in');
print('🔑 Please create admin user via /register endpoint');
print('⚠️  Remember to change default credentials in production!');
