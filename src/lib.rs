use tauri::Runtime;

pub struct Fcm<R: Runtime>(tauri::plugin::PluginHandle<R>);

impl<R: Runtime> Fcm<R> {
    /// Initialize the FCM plugin
    pub fn new(handle: tauri::plugin::PluginHandle<R>) -> Self {
        Self(handle)
    }

    /// Get the FCM token
    pub fn get_token(&self) -> crate::Result<String> {
        self.0
            .run_mobile_plugin("getToken", ())
            .map_err(Into::into)
    }

    /// Subscribe to a topic
    pub fn subscribe_to_topic(&self, topic: String) -> crate::Result<()> {
        self.0
            .run_mobile_plugin("subscribeToTopic", topic)
            .map_err(Into::into)
    }

    /// Unsubscribe from a topic
    pub fn unsubscribe_from_topic(&self, topic: String) -> crate::Result<()> {
        self.0
            .run_mobile_plugin("unsubscribeFromTopic", topic)
            .map_err(Into::into)
    }

    /// Check if notifications are enabled
    pub fn are_notifications_enabled(&self) -> crate::Result<bool> {
        self.0
            .run_mobile_plugin("areNotificationsEnabled", ())
            .map_err(Into::into)
    }

    /// Request notification permission
    pub fn request_notification_permission(&self) -> crate::Result<bool> {
        self.0
            .run_mobile_plugin("requestNotificationPermission", ())
            .map_err(Into::into)
    }

    /// Delete the FCM token
    pub fn delete_token(&self) -> crate::Result<()> {
        self.0
            .run_mobile_plugin("deleteToken", ())
            .map_err(Into::into)
    }

    /// Get the last received message
    pub fn get_last_message(&self) -> crate::Result<Option<serde_json::Value>> {
        self.0
            .run_mobile_plugin("getLastMessage", ())
            .map_err(Into::into)
    }
}

#[cfg(desktop)]
mod desktop {
    use super::*;

    pub fn init<R: Runtime>() -> tauri::plugin::TauriPlugin<R> {
        tauri::plugin::Builder::new("fcm")
            .invoke_handler(tauri::generate_handler![
                get_token,
                subscribe_to_topic,
                unsubscribe_from_topic,
                are_notifications_enabled,
                request_notification_permission,
                delete_token,
                get_last_message
            ])
            .build()
    }

    #[tauri::command]
    async fn get_token() -> std::result::Result<String, String> {
        Err("FCM is not supported on desktop".to_string())
    }

    #[tauri::command]
    async fn subscribe_to_topic(_topic: String) -> std::result::Result<(), String> {
        Err("FCM is not supported on desktop".to_string())
    }

    #[tauri::command]
    async fn unsubscribe_from_topic(_topic: String) -> std::result::Result<(), String> {
        Err("FCM is not supported on desktop".to_string())
    }

    #[tauri::command]
    async fn are_notifications_enabled() -> std::result::Result<bool, String> {
        Err("FCM is not supported on desktop".to_string())
    }

    #[tauri::command]
    async fn request_notification_permission() -> std::result::Result<bool, String> {
        Err("FCM is not supported on desktop".to_string())
    }

    #[tauri::command]
    async fn delete_token() -> std::result::Result<(), String> {
        Err("FCM is not supported on desktop".to_string())
    }

    #[tauri::command]
    async fn get_last_message() -> std::result::Result<Option<serde_json::Value>, String> {
        Err("FCM is not supported on desktop".to_string())
    }
}

#[cfg(mobile)]
pub mod mobile {
    use super::*;

    pub fn init<R: Runtime>() -> tauri::plugin::TauriPlugin<R> {
        tauri::plugin::Builder::new("fcm")
            .invoke_handler(tauri::generate_handler![
                get_token,
                subscribe_to_topic,
                unsubscribe_from_topic,
                are_notifications_enabled,
                request_notification_permission,
                delete_token,
                get_last_message
            ])
            .build()
    }

    #[tauri::command]
    async fn get_token() -> std::result::Result<String, String> {
        Err("FCM mobile implementation not available".to_string())
    }

    #[tauri::command]
    async fn subscribe_to_topic(_topic: String) -> std::result::Result<(), String> {
        Err("FCM mobile implementation not available".to_string())
    }

    #[tauri::command]
    async fn unsubscribe_from_topic(_topic: String) -> std::result::Result<(), String> {
        Err("FCM mobile implementation not available".to_string())
    }

    #[tauri::command]
    async fn are_notifications_enabled() -> std::result::Result<bool, String> {
        Err("FCM mobile implementation not available".to_string())
    }

    #[tauri::command]
    async fn request_notification_permission() -> std::result::Result<bool, String> {
        Err("FCM mobile implementation not available".to_string())
    }

    #[tauri::command]
    async fn delete_token() -> std::result::Result<(), String> {
        Err("FCM mobile implementation not available".to_string())
    }

    #[tauri::command]
    async fn get_last_message() -> std::result::Result<Option<serde_json::Value>, String> {
        Err("FCM mobile implementation not available".to_string())
    }
}

pub type Result<T> = std::result::Result<T, Box<dyn std::error::Error + Send + Sync>>;

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    // This entry point is required for mobile plugins
    // The actual plugin initialization happens in the main app
}