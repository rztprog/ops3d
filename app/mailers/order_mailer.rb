class OrderMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.paid_confirmation.subject
  #

  def paid_confirmation
    @order = params[:order]

    mail(
      to: @order.email,
      subject: "Confirmation de ta commande ##{@order.id}"
    )
  end

  def admin_paid_notification
    @order = params[:order]

    mail(
      to: ENV.fetch("ADMIN_EMAIL"),
      subject: "Nouvelle commande payée ##{@order.id}"
    )
  end
end
