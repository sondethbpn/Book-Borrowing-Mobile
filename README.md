# Mobile App Project

A full-stack mobile application combining Flutter frontend with a Node.js/Express backend.

## Project Structure

```
├── app/                  # Flutter mobile application
├── server/              # Node.js/Express backend server
│   ├── server_mobile.js # Main server file
│   └── db.js           # Database configuration
├── connection_demo/     # Demo code for connection testing
└── uploads/            # File upload directory
```

## Features

- **User Authentication**: JWT-based authentication with bcrypt password hashing
- **User Roles**: Admin and user role-based access control
- **File Upload**: Integration with Cloudinary for image/file storage
- **Session Management**: Express session management with MySQL session store
- **Mobile UI**: Flutter-based cross-platform mobile application

## Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile app framework

### Backend
- **Node.js** - JavaScript runtime
- **Express.js** - Web framework
- **MySQL** - Database
- **Cloudinary** - Cloud storage for media files

### Key Dependencies
- `bcrypt` - Password hashing
- `jsonwebtoken` - JWT authentication
- `express-session` - Session management
- `multer` - File upload handling
- `cors` - Cross-origin resource sharing
- `dotenv` - Environment variable management

## Getting Started

### Prerequisites
- Node.js and npm
- Flutter SDK
- MySQL database

### Backend Setup

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file in the root directory with your configuration:
```
DATABASE_HOST=localhost
DATABASE_USER=root
DATABASE_PASSWORD=your_password
DATABASE_NAME=your_database
JWT_SECRET=your_secret_key
CLOUDINARY_NAME=your_cloudinary_name
CLOUDINARY_KEY=your_cloudinary_key
CLOUDINARY_SECRET=your_cloudinary_secret
```

3. Start the development server:
```bash
npm run dev
```

The server will start with nodemon for automatic restarts on file changes.

### Frontend Setup

1. Navigate to the app directory:
```bash
cd app
```

2. Get Flutter dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## API Endpoints

The backend provides RESTful APIs for:
- User authentication (login/signup)
- Borrowing requests
- Browsing student profiles
- Request history and status tracking
- File uploads

## Database

The project uses MySQL for data persistence with session storage enabled for maintaining user sessions.

## File Upload

Files are uploaded to Cloudinary for cloud storage. Ensure Cloudinary credentials are properly configured in your `.env` file.

## License

ISC

## Author

[Your Name/Organization]
