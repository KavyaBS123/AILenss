const AWS = require('aws-sdk');
const multer = require('multer');
const path = require('path');

// Configure AWS S3
const s3 = new AWS.S3({
  accessKeyId: process.env.AWS_ACCESS_KEY_ID,
  secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
  region: process.env.AWS_REGION,
});

// Configure multer for in-memory storage before uploading to S3
const storage = multer.memoryStorage();

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 100 * 1024 * 1024, // 100MB limit for video files
  },
  fileFilter: (req, file, cb) => {
    // Allow video and other media files
    const allowedMimes = [
      'video/mp4',
      'video/mpeg',
      'image/jpeg',
      'image/png',
      'audio/mpeg',
      'audio/wav',
    ];

    if (allowedMimes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type. Only video, image, and audio files are allowed.'));
    }
  },
});

// Function to upload file to S3
const uploadToS3 = async (file, userId, fileType) => {
  const filename = `${fileType}/${userId}/${Date.now()}-${file.originalname}`;

  const params = {
    Bucket: process.env.AWS_S3_BUCKET,
    Key: filename,
    Body: file.buffer,
    ContentType: file.mimetype,
    ACL: 'private', // Private access by default
  };

  try {
    const result = await s3.upload(params).promise();
    console.log(`File uploaded to S3: ${result.Location}`);
    return result.Location;
  } catch (error) {
    console.error(`Error uploading to S3: ${error.message}`);
    throw error;
  }
};

// Function to delete file from S3
const deleteFromS3 = async (fileUrl) => {
  // Extract key from S3 URL
  const key = fileUrl.split('.amazonaws.com/')[1];

  const params = {
    Bucket: process.env.AWS_S3_BUCKET,
    Key: key,
  };

  try {
    await s3.deleteObject(params).promise();
    console.log(`File deleted from S3: ${key}`);
  } catch (error) {
    console.error(`Error deleting from S3: ${error.message}`);
    throw error;
  }
};

module.exports = {
  upload,
  uploadToS3,
  deleteFromS3,
  s3,
};
