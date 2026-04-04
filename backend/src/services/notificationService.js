const prisma = require('../models/prisma');

class NotificationService {
  /**
   * Create a notification for a user
   * @param {string} userId
   * @param {string} title
   * @param {string} message
   * @param {string} type - TRANSACTION, REWARD, SYSTEM
   */
  async notify(userId, title, message, type = 'SYSTEM') {
    try {
      return await prisma.notification.create({
        data: {
          userId,
          title,
          message,
          type
        }
      });
    } catch (error) {
      console.error('NotificationService Error:', error);
      return null;
    }
  }

  /**
   * Get user notifications
   */
  async getNotifications(userId) {
    return await prisma.notification.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: 50
    });
  }

  /**
   * Mark as read
   */
  async markRead(notificationId) {
    return await prisma.notification.update({
      where: { id: notificationId },
      data: { read: true }
    });
  }
}

module.exports = new NotificationService();
