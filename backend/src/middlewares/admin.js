const prisma = require('../models/prisma');

const adminMiddleware = async (req, res, next) => {
  try {
    const { userId } = req.user;

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { role: true },
    });

    if (!user || user.role !== 'ADMIN') {
      return res.status(403).json({ success: false, message: 'Forbidden. Admin privileges required.' });
    }

    next();
  } catch (error) {
    console.error('Admin Middleware Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

module.exports = adminMiddleware;
