const prisma = require('../models/prisma');

const superAdminMiddleware = async (req, res, next) => {
  try {
    const { userId } = req.user;

    const user = await prisma.user.findUnique({
      where: { id: userId },
      select: { role: true },
    });

    if (!user || user.role !== 'SUPER_ADMIN') {
      return res.status(403).json({ success: false, message: 'Forbidden. Super Admin privileges required.' });
    }

    next();
  } catch (error) {
    console.error('Super Admin Middleware Error:', error);
    return res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

module.exports = superAdminMiddleware;
