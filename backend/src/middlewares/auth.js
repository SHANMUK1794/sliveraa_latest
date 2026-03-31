const jwt = require('jsonwebtoken');

const authMiddleware = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({ 
        error: 'Authentication failed',
        message: 'No authorization token provided'
      });
    }

    const token = authHeader.split(' ')[1];
    const secret = process.env.JWT_SECRET || 'fallback_secret';

    const decoded = jwt.verify(token, secret);
    
    // Attach user information to the request
    req.user = {
      userId: decoded.userId,
      phone: decoded.phone || decoded.phoneNumber
    };
    
    next();
  } catch (error) {
    console.error('Auth Middleware Error:', error.message);
    return res.status(401).json({ 
      error: 'Authentication failed',
      message: 'Invalid or expired token'
    });
  }
};

module.exports = authMiddleware;
