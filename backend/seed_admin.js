const mongoose = require('mongoose');
const dotenv = require('dotenv');
const User = require('./models/User');
const connectDB = require('./config/db');

dotenv.config();
connectDB();

const createAdmin = async () => {
    try {
        const adminEmail = 'admin@police.com';
        const adminPass = '123456';

        const userExists = await User.findOne({ email: adminEmail });

        if (userExists) {
            console.log('Admin user already exists. Updating role to admin...');
            userExists.role = 'admin';
            userExists.password = adminPass;
            // Backfill required fields if missing
            if (!userExists.phone) userExists.phone = '0610000000';
            if (!userExists.address) userExists.address = 'Police HQ';

            await userExists.save();
            console.log('Admin updated.');
        } else {
            console.log('Creating new Admin user...');
            await User.create({
                name: 'Police Admin',
                email: adminEmail,
                password: adminPass,
                phone: '0610000000',
                address: 'Police HQ',
                role: 'admin'
            });
            console.log('Admin created.');
        }

        console.log('-----------------------------------');
        console.log('Admin Login Details:');
        console.log(`Email: ${adminEmail}`);
        console.log(`Password: ${adminPass}`);
        console.log('-----------------------------------');
        process.exit();
    } catch (error) {
        console.error(`Error: ${error.message}`);
        process.exit(1);
    }
};

createAdmin();
