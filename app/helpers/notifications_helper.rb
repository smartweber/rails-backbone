module NotificationsHelper

  def notification_text_for(notification)
    case notification.notification_type
    when "new_message"
      t("notifications.#{notification.notification_type}.description", notifiable_name: notification.notifiable.user.name,
                                                           notifiable_body: notification.notifiable.body)
    else
      t("notifications.#{notification.notification_type}.description", notifiable_name: notification.notifiable.name)
    end
  end
end
