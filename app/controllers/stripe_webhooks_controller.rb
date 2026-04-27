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
    order = Order.find_by(stripe_checkout_session_id: session.id)
    return unless order
    return if order.status == "paid"

    order.update!(
      status: "paid",
      stripe_payment_intent_id: session.payment_intent
    )

    # Envoie du mail une fois la commande confirmé
    OrderMailer.with(order: order).paid_confirmation.deliver_later
    OrderMailer.with(order: order).admin_paid_notification.deliver_later
  end
end
