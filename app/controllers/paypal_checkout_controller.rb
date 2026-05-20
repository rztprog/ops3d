class PaypalCheckoutsController < ApplicationController
  before_action :set_order

  def create
    # crée un order PayPal via API
    # stocke paypal_order_id
    # redirect vers approve link PayPal
  end

  def success
    # capture l'order PayPal côté serveur
    # marque order paid si capture completed
  end

  def cancel
    redirect_to order_path(@order), alert: "Paiement PayPal annulé."
  end

  private

  def set_order
    @order = Order.find(params[:order_id])
    # même logique d'autorisation que Stripe/guest
  end
end
