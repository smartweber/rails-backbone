atom_feed do |feed|
  feed.title "Unseen Notifications"
  feed.updated @notifications.maximum(:updated_at) if @notifications.any?

  @notifications.each do |notification|
    feed.entry notification, published: notification.updated_at do |entry|
      entry.title t("notifications.#{notification.notification_type}.title")
      entry.content notification_text_for(notification)
    end
  end
end
