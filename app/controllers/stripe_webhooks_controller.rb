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
      session = event.data.object
      fulfill_order(session)
    end

    head :ok
  rescue JSON::ParserError
    head :bad_request
  rescue Stripe::SignatureVerificationError
    head :bad_request
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
  end
end
