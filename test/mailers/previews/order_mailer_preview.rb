# Preview all emails at http://localhost:3000/rails/mailers/order_mailer
class OrderMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/order_mailer/paid_confirmation
  def paid_confirmation
    OrderMailer.paid_confirmation
  end
end
