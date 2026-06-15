class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAIL_FROM", "OPS3D <contact@ops3d.fr>")
  layout "mailer"
end
