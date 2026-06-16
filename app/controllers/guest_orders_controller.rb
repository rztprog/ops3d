class GuestOrdersController < ApplicationController
  before_action :redirect_authenticated_user

  def index
    ids = session[:guest_order_ids] || []

    @orders = Order
      .where(id: ids)
      .order(created_at: :desc)
  end

  private

  def redirect_authenticated_user
    return unless user_signed_in?

    redirect_to account_orders_path,
      notice: "Tes commandes sont disponibles ici dans ton compte."
  end
end
