class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("SMTP_USERNAME", "contact@ops3d.fr")
  layout "mailer"
end
