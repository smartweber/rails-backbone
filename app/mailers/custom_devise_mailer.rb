class CustomDeviseMailer < Devise::Mailer
  include SendGrid
  helper :application # gives access to all helpers defined within `application_helper`.
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  sendgrid_category :use_subject_lines
  default from: %("Stockharp" <no-reply@#{Rails.configuration.action_mailer.default_url_options[:host]}>),
    reply_to: %("Stockharp" <no-reply@#{Rails.configuration.action_mailer.default_url_options[:host]}>),
    template_path: 'devise/mailer' # to make sure that your mailer uses the devise views

  def confirmation_instructions(record, token, opts={})
    self.class.sendgrid_template "00925530-7a93-4a39-9ef8-d1073548f59d"
    sendgrid_recipients [record.email]
    sendgrid_substitute '-name-', [record.name]
    sendgrid_substitute '-confirmationUrl-', [confirmation_url(record, confirmation_token: record.confirmation_token)]
    super
  end

  def reset_password_instructions(record, token, opts={})
    self.class.sendgrid_template "69b67629-cd14-40c1-87cf-3579785f655b"
    sendgrid_recipients [record.email]
    sendgrid_substitute '-name-', [record.name]
    sendgrid_substitute '-resetPasswordUrl-', [edit_password_url(record, reset_password_token: token)]
    super
  end

  def unlock_instructions(record, token, opts={})
    super
  end
end
