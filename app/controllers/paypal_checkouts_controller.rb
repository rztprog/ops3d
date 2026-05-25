class PaypalCheckoutsController < ApplicationController
  before_action :set_order

  def create
    access_token = paypal_access_token

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
      payment_provider: "paypal",
      paypal_order_id: body["id"]
    )

    approve_url = body["links"]
      .find { |l| l["rel"] == "approve" }

    redirect_to approve_url["href"], allow_other_host: true
  end

  def success
    redirect_to order_path(@order),
      notice: "Paiement PayPal à finaliser"
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
