require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const User = require('./models/UserModel');

async function resetPassword() {
  try {
    // Find the user
    const user = await User.findOne({ email: 'bhumiinteriorsolution@gmail.com' });
    
    if (!user) {
      console.log('❌ User not found');
      process.exit(1);
    }

    // Hash the new password
    const hashedPassword = await bcrypt.hash('bhumiinteriorsolution@2026', 10);
    
    // Update the password
    user.password = hashedPassword;
    await user.save();

    console.log('✅ Password successfully reset for:', user.email);
    console.log('📧 Email:', user.email);
    console.log('🔐 New Password: bhumiinteriorsolution@2026');
    console.log('👤 Role:', user.role);
    console.log('📅 Created:', user.createdAt);
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error resetting password:', error);
    process.exit(1);
  }
}

resetPassword();
