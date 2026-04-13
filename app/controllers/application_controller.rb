class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Guest_token pour le panier
  before_action :set_guest_token

  def current_cart
    if user_signed_in?
      current_user.cart || current_user.create_cart
    else
      Cart.find_or_create_by!(guest_token: session[:guest_token])
    end
  end

  def set_guest_token
    session[:guest_token] ||= SecureRandom.uuid
  end
end
