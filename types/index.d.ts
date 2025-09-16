declare module '@tauri-apps/plugin-fcm' {
  export interface FcmToken {
    token: string;
  }

  export interface TopicArgs {
    topic: string;
  }

  export interface NotificationPermission {
    granted: boolean;
  }

  export interface NotificationStatus {
    enabled: boolean;
  }

  export interface FcmMessage {
    messageId?: string;
    from?: string;
    to?: string;
    messageType?: string;
    sentTime?: number;
    ttl?: number;
    notification?: {
      title?: string;
      body?: string;
      icon?: string;
      color?: string;
      sound?: string;
      tag?: string;
      clickAction?: string;
    };
    data?: Record<string, string>;
  }

  export interface FcmTokenEvent {
    token: string;
    timestamp: number;
  }

  export interface FcmTopicEvent {
    topic: string;
    action: 'subscribed' | 'unsubscribed';
  }

  export interface FcmErrorEvent {
    error: string;
  }

  export interface PluginListener {
    unlisten: () => void;
  }

  export class Fcm {
    /**
     * Get the FCM registration token
     */
    getToken(): Promise<string>;

    /**
     * Subscribe to a topic
     */
    subscribeToTopic(topic: string): Promise<void>;

    /**
     * Unsubscribe from a topic
     */
    unsubscribeFromTopic(topic: string): Promise<void>;

    /**
     * Check if notifications are enabled
     */
    areNotificationsEnabled(): Promise<boolean>;

    /**
     * Request notification permission
     */
    requestNotificationPermission(): Promise<boolean>;

    /**
     * Delete the FCM token
     */
    deleteToken(): Promise<void>;

    /**
     * Get the last received message
     */
    getLastMessage(): Promise<FcmMessage | null>;

    /**
     * Listen for FCM token received events
     */
    onTokenReceived(handler: (event: FcmTokenEvent) => void): Promise<PluginListener>;

    /**
     * Listen for FCM token refresh events
     */
    onTokenRefresh(handler: (event: FcmTokenEvent) => void): Promise<PluginListener>;

    /**
     * Listen for FCM message received events
     */
    onMessageReceived(handler: (event: FcmMessage) => void): Promise<PluginListener>;

    /**
     * Listen for FCM topic change events
     */
    onTopicChanged(handler: (event: FcmTopicEvent) => void): Promise<PluginListener>;

    /**
     * Listen for FCM token deleted events
     */
    onTokenDeleted(handler: (event: { action: string }) => void): Promise<PluginListener>;

    /**
     * Listen for FCM token error events
     */
    onTokenError(handler: (event: FcmErrorEvent) => void): Promise<PluginListener>;
  }

  export function createFcm(): Fcm;
}
