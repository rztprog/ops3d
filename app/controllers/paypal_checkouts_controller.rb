class PaypalCheckoutsController < ApplicationController
  before_action :set_order

  def create
    access_token = paypal_access_token

    unless @order.status == "pending"
      redirect_to order_path(@order), alert: "Cette commande ne peut plus être payée."
      return
    end

    response = HTTParty.post(
      paypal_api_url("/v2/checkout/orders"),
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{access_token}"
      },
      body: {
        intent: "CAPTURE",
        purchase_units: [
          {
            amount: {
              currency_code: "EUR",
              value: format("%.2f", @order.total_price_cents / 100.0)
            }
          }
        ],
        application_context: {
          return_url: success_order_paypal_checkout_url(@order),
          cancel_url: cancel_order_paypal_checkout_url(@order)
        }
      }.to_json
    )

    body = JSON.parse(response.body)

    @order.update!(
      payment_provider: "Paypal",
      paypal_order_id: body["id"]
    )

    approve_url = body["links"]
      .find { |l| l["rel"] == "approve" }

    redirect_to approve_url["href"], allow_other_host: true
  end

  def success
    if @order.status == "paid"
      redirect_to order_path(@order), notice: "Commande déjà payée."
      return
    end

    access_token = paypal_access_token

    response = HTTParty.post(
      paypal_api_url("/v2/checkout/orders/#{@order.paypal_order_id}/capture"),
      headers: {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{access_token}"
      },
      body: {}.to_json
    )

    body = JSON.parse(response.body)

    unless response.success?
      Rails.logger.error("[PayPalCapture] order_id=#{@order.id} response=#{body}")
      redirect_to order_path(@order), alert: "Le paiement PayPal n'a pas pu être confirmé."
      return
    end

    capture = body.dig("purchase_units", 0, "payments", "captures", 0)

    unless body["status"] == "COMPLETED" && capture&.dig("status") == "COMPLETED"
      Rails.logger.error("[PayPalCapture] order_id=#{@order.id} unexpected_status=#{body}")
      redirect_to order_path(@order), alert: "Le paiement PayPal n'est pas confirmé."
      return
    end

    should_send_emails = false

    Order.transaction do
      @order.lock!

      unless @order.status == "paid"
        @order.update!(
          status: "paid",
          payment_provider: "Paypal",
          paypal_capture_id: capture["id"]
        )

        should_send_emails = true
      end
    end

    if should_send_emails
      OrderMailer.with(order: @order).paid_confirmation.deliver_later
      OrderMailer.with(order: @order).admin_paid_notification.deliver_later
    end

    redirect_to order_path(@order), notice: "Paiement PayPal confirmé."
  end

  def cancel
    redirect_to order_path(@order),
      alert: "Paiement annulé"
  end

  private

  def set_order
    @order = Order.find(params[:order_id])

    return if user_signed_in? && @order.user_id == current_user.id
    return if session[:guest_order_ids]&.include?(@order.id)

    redirect_to root_path, alert: "Accès refusé."
  end

  def paypal_access_token
    response = HTTParty.post(
      "#{paypal_base_url}/v1/oauth2/token",
      basic_auth: {
        username: ENV["PAYPAL_CLIENT_ID"],
        password: ENV["PAYPAL_CLIENT_SECRET"]
      },
      body: {
        grant_type: "client_credentials"
      }
    )

    JSON.parse(response.body)["access_token"]
  end

  def paypal_base_url
    ENV["PAYPAL_MODE"] == "production" ?
      "https://api-m.paypal.com" :
      "https://api-m.sandbox.paypal.com"
  end

  def paypal_api_url(path)
    "#{paypal_base_url}#{path}"
  end
end
