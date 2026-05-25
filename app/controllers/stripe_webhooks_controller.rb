class StripeWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    payload = request.body.read
    signature = request.env["HTTP_STRIPE_SIGNATURE"]

    event = Stripe::Webhook.construct_event(
      payload,
      signature,
      ENV["STRIPE_WEBHOOK_SECRET"]
    )

    Rails.logger.info(
      "[StripeWebhook] event=#{event.type} stripe_event_id=#{event.id}"
    )

    case event.type
    when "checkout.session.completed"
      fulfill_order(event.data.object)
    else
      Rails.logger.info "Unhandled Stripe event: #{event.type}"
    end

    head :ok
  rescue JSON::ParserError => e
    Rails.logger.error "Stripe JSON error: #{e.message}"
    head :bad_request
  rescue Stripe::SignatureVerificationError => e
    Rails.logger.error "Stripe signature error: #{e.message}"
    head :bad_request
  rescue => e
    Rails.logger.error "Stripe webhook error: #{e.class} - #{e.message}"
    head :internal_server_error
  end

  private

  def fulfill_order(session)
    order = Order.find_by(id: session.metadata.order_id)
    return unless order
    return unless order.user_id.to_s == session.metadata.user_id.to_s
    should_send_emails = false

    Order.transaction do
      # Pour prevenir d'une double modification SQL
      order.lock!

      return if order.status == "paid"

      order.update!(
        status: "paid",
        stripe_checkout_session_id: session.id,
        stripe_payment_intent_id: session.payment_intent,
        payment_provider: "stripe"
      )

      should_send_emails = true
    end

    # Envoie des 2 mails (admin + user) une fois la commande confirmé
    if should_send_emails
      Rails.logger.info(
        "[Mailer] paid_confirmation order_id=#{order.id}"
      )
      OrderMailer.with(order: order).paid_confirmation.deliver_later
      OrderMailer.with(order: order).admin_paid_notification.deliver_later
    end
  end
end
