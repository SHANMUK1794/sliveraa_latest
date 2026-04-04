const notificationService = require('../services/notificationService');

class NotificationController {
  /**
   * Get all notifications for user
   */
  async getNotifications(req, res) {
    try {
      const { id: userId } = req.user;
      const notifications = await notificationService.getNotifications(userId);
      res.json({ success: true, notifications });
    } catch (error) {
      res.status(500).json({ error: 'Failed to fetch notifications' });
    }
  }

  /**
   * Mark a notification as read
   */
  async markAsRead(req, res) {
    try {
      const { id } = req.params;
      await notificationService.markRead(id);
      res.json({ success: true, message: 'Notification marked as read' });
    } catch (error) {
      res.status(500).json({ error: 'Failed to update notification' });
    }
  }
}

module.exports = new NotificationController();
