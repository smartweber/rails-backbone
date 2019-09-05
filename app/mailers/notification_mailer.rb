class NotificationMailer < ActionMailer::Base
  default from: %("Stockharp Notifications" <no-reply@#{Rails.configuration.action_mailer.default_url_options[:host]}>),
    reply_to: %("Stockharp Notifications" <no-reply@#{Rails.configuration.action_mailer.default_url_options[:host]}>)

  def new_notification_email(user_id, notification_id)
    @user         = User.find(user_id)
    @notification = Notification.find(notification_id)
    mail to: @user.email, subject: "New notification", template_name: "#{@notification.notification_type}_email"
  end
end
