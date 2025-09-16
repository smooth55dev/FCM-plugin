import { invoke, addPluginListener } from '@tauri-apps/api/core';

/**
 * FCM Plugin JavaScript Wrapper
 */
export class Fcm {
  /**
   * Get the FCM registration token
   * @returns {Promise<string>} The FCM token
   */
  async getToken() {
    return await invoke('plugin:fcm|getToken');
  }

  /**
   * Subscribe to a topic
   * @param {string} topic - The topic to subscribe to
   * @returns {Promise<void>}
   */
  async subscribeToTopic(topic) {
    return await invoke('plugin:fcm|subscribeToTopic', { topic });
  }

  /**
   * Unsubscribe from a topic
   * @param {string} topic - The topic to unsubscribe from
   * @returns {Promise<void>}
   */
  async unsubscribeFromTopic(topic) {
    return await invoke('plugin:fcm|unsubscribeFromTopic', { topic });
  }

  /**
   * Check if notifications are enabled
   * @returns {Promise<boolean>} True if notifications are enabled
   */
  async areNotificationsEnabled() {
    return await invoke('plugin:fcm|areNotificationsEnabled');
  }

  /**
   * Request notification permission
   * @returns {Promise<boolean>} True if permission was granted
   */
  async requestNotificationPermission() {
    return await invoke('plugin:fcm|requestNotificationPermission');
  }

  /**
   * Delete the FCM token
   * @returns {Promise<void>}
   */
  async deleteToken() {
    return await invoke('plugin:fcm|deleteToken');
  }

  /**
   * Get the last received message
   * @returns {Promise<Object|null>} The last message or null if none
   */
  async getLastMessage() {
    return await invoke('plugin:fcm|getLastMessage');
  }

  /**
   * Listen for FCM token received events
   * @param {Function} handler - Handler function for token received events
   * @returns {Promise<Object>} Plugin listener object
   */
  async onTokenReceived(handler) {
    return await addPluginListener('fcm', 'tokenReceived', handler);
  }

  /**
   * Listen for FCM token refresh events
   * @param {Function} handler - Handler function for token refresh events
   * @returns {Promise<Object>} Plugin listener object
   */
  async onTokenRefresh(handler) {
    return await addPluginListener('fcm', 'tokenRefresh', handler);
  }

  /**
   * Listen for FCM message received events
   * @param {Function} handler - Handler function for message received events
   * @returns {Promise<Object>} Plugin listener object
   */
  async onMessageReceived(handler) {
    return await addPluginListener('fcm', 'messageReceived', handler);
  }

  /**
   * Listen for FCM topic change events
   * @param {Function} handler - Handler function for topic change events
   * @returns {Promise<Object>} Plugin listener object
   */
  async onTopicChanged(handler) {
    return await addPluginListener('fcm', 'topicChanged', handler);
  }

  /**
   * Listen for FCM token deleted events
   * @param {Function} handler - Handler function for token deleted events
   * @returns {Promise<Object>} Plugin listener object
   */
  async onTokenDeleted(handler) {
    return await addPluginListener('fcm', 'tokenDeleted', handler);
  }

  /**
   * Listen for FCM token error events
   * @param {Function} handler - Handler function for token error events
   * @returns {Promise<Object>} Plugin listener object
   */
  async onTokenError(handler) {
    return await addPluginListener('fcm', 'tokenError', handler);
  }
}

/**
 * Create a new FCM instance
 * @returns {Fcm} FCM instance
 */
export function createFcm() {
  return new Fcm();
}

// Default export
export default Fcm;
