class GuestOrdersController < ApplicationController
  def index
    ids = session[:guest_order_ids] || []

    @orders = Order
      .where(id: ids)
      .order(created_at: :desc)
  end
end
