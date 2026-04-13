class CartsController < ApplicationController
  def show
    @cart = current_cart || ensure_cart
  end
end
