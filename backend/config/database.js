const mongoose = require('mongoose');

const connectDB = async () => {
  try {
    const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/ailens';
    const conn = await mongoose.connect(uri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
      serverSelectionTimeoutMS: 5000,
    });

    console.log(`✅ MongoDB Connected: ${conn.connection.host}`);
    return conn;
  } catch (error) {
    console.error(`❌ Error connecting to MongoDB: ${error.message}`);
    console.log('\n⚠️  MongoDB Connection Failed');
    console.log('Solution: Start MongoDB with: mongod');
    console.log('Or use MongoDB Atlas: https://mongodb.com/cloud/atlas\n');
    // Don't exit - allow testing without DB
    console.log('Running in TEST mode (database features limited)\n');
  }
};

module.exports = connectDB;
