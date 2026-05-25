class PaypalWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    event = JSON.parse(request.body.read)

    Rails.logger.info(
      "[PayPalWebhook] event=#{event["event_type"]} id=#{event["id"]}"
    )

    case event["event_type"]
    when "PAYMENT.CAPTURE.COMPLETED"
      handle_capture_completed(event)
    else
      Rails.logger.info("[PayPalWebhook] unhandled=#{event["event_type"]}")
    end

    head :ok
  rescue JSON::ParserError => e
    Rails.logger.error("[PayPalWebhook] JSON error=#{e.message}")
    head :bad_request
  rescue => e
    Rails.logger.error("[PayPalWebhook] error=#{e.class} #{e.message}")
    head :internal_server_error
  end

  private

  def handle_capture_completed(event)
    capture = event["resource"]
    paypal_order_id = capture.dig("supplementary_data", "related_ids", "order_id")

    return if paypal_order_id.blank?

    order = Order.find_by(paypal_order_id: paypal_order_id)
    return unless order

    should_send_emails = false

    Order.transaction do
      order.lock!

      return if order.status == "paid"

      order.update!(
        status: "paid",
        payment_provider: "paypal",
        paypal_capture_id: capture["id"]
      )

      should_send_emails = true
    end

    if should_send_emails
      OrderMailer.with(order: order).paid_confirmation.deliver_later
      OrderMailer.with(order: order).admin_paid_notification.deliver_later
    end
  end
end
