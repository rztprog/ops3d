class PagesController < ApplicationController
  def home
  end

  def current_cart
    if user_signed_in?
      current_user.cart || current_user.create_cart
    else
      Cart.find_or_create_by(guest_token: session[:guest_token])
    end
  end
end
