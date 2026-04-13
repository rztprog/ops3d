class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Guest_token pour le panier
  before_action :set_guest_token

  # Rend le current_cart dispo dans toutes vues
  helper_method :current_cart

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

  # Override la fonction pour merge after_sign_in_path_for si on se connecte
  def after_sign_in_path_for(resource)
    merge_carts if session[:guest_token].present?
    super
  end

  def merge_carts
    guest_cart = Cart.find_by(guest_token: session[:guest_token])
    return unless guest_cart

    user_cart = current_user.cart || current_user.create_cart

    guest_cart.cart_items.each do |item|
      existing_item = user_cart.cart_items.find_by(product_id: item.product_id)

      if existing_item
        existing_item.quantity += item.quantity
        existing_item.save!
      else
        item.update!(cart: user_cart)
      end
    end

    # Supprime le guest_cart et le guest_token une fois mergé
    guest_cart.destroy
    session[:guest_token] = nil
  end
end
