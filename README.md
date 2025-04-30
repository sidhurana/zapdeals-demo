# ZapDeals

ZapDeals is a deals aggregation application that fetches and displays deals from various e-commerce platforms like eBay, Amazon, BestBuy, etc.

## Application Structure

### Frontend
- React application with React-Bootstrap for UI components
- Components for navigation, search, category filtering, and deal display
- Firebase Authentication with Google Sign-In

### Backend
- FastAPI server with Firebase authentication
- API integration with e-commerce platforms
- Deal filtering and formatting

## Features
- Category-based filtering (Electronics, Gaming, Home & Kitchen, Fashion, etc.)
- Search functionality for filtering deals by title
- Authentication with Google
- Responsive design with Bootstrap components
- Direct links to e-commerce sites for viewing/purchasing deals

## Tech Stack
- **Frontend**: React, React-Bootstrap, Firebase, Axios
- **Backend**: FastAPI, Firebase Admin, Requests
- **Authentication**: Firebase Authentication
- **Data Sources**: Demo data (in production would use eBay API, Amazon API, etc.)

## Setup and Installation

### Frontend
```bash
cd frontend
npm install
npm start
```

### Backend
```bash
cd backend
pip install -r requirements.txt
uvicorn main:app --reload
```

## Deployment on Amazon Linux 2 EC2

To deploy the application on an Amazon Linux 2 EC2 instance:

1. SSH into your EC2 instance:
   ```
   ssh -i your-key.pem ec2-user@your-ec2-ip
   ```

2. Clone the repository:
   ```
   git clone https://github.com/sidhurana/zapdeals-demo.git
   ```

3. Navigate to the project directory:
   ```
   cd zapdeals-demo
   ```

4. Make the deployment script executable:
   ```
   chmod +x deploy.sh
   ```

5. Run the deployment script:
   ```
   ./deploy.sh
   ```

6. The application will be accessible at http://your-ec2-ip

## Security Considerations

- The Firebase configuration in `firebase.js` uses placeholder values. In a production environment, you should replace these with your actual Firebase project credentials.
- For a production deployment, consider setting up HTTPS using Let's Encrypt or AWS Certificate Manager.
- Implement proper error handling and input validation in both frontend and backend.

## Demo Data
This repository includes demo data for development and testing purposes since it doesn't have actual API access to e-commerce platforms.