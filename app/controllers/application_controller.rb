class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # Localizations
  before_action :set_locale

  # Guest_token pour le panier
  before_action :set_guest_token

  # Autorise les champs devise
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Rend le current_cart dispo dans toutes vues
  helper_method :current_cart

  # Si il ya un déclenchement de RecordNotFound
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def current_cart
    if user_signed_in?
      current_user.cart
    else
      Cart.find_by(guest_token: session[:guest_token])
    end
  end

  def ensure_cart
    if user_signed_in?
      current_user.cart || current_user.create_cart
    else
      Cart.find_or_create_by!(guest_token: session[:guest_token])
    end
  end

  # Override la fonction pour merge after_sign_in_path_for si on se connecte
  def after_sign_in_path_for(resource)
    merge_carts if session[:guest_token].present?
    super
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :first_name, :last_name ])
  end

  def require_admin!
    unless user_signed_in? && current_user.admin?
      redirect_to root_path, alert: "Tu cherches quelques chose ? 😁"
    end
  end

  private

  def record_not_found
    redirect_to account_path, alert: "Commande introuvable."
  end

  def set_locale
    locale = params[:locale] || session[:locale] || I18n.default_locale
    locale = locale.to_sym

    I18n.locale = I18n.available_locales.include?(locale) ? locale : I18n.default_locale
    session[:locale] = I18n.locale
  end

  def default_url_options
    { locale: I18n.locale }
  end

  def set_guest_token
    session[:guest_token] ||= SecureRandom.uuid
  end

  def merge_carts
    guest_cart = Cart.find_by(guest_token: session[:guest_token])
    return unless guest_cart

    user_cart = current_user.cart || current_user.create_cart

    guest_cart.cart_items.includes(:cart_item_custom_field_values).find_each do |item|
      if item.cart_item_custom_field_values.any?
        item.update!(cart: user_cart)
      else
        existing_item = user_cart.cart_items
          .left_outer_joins(:cart_item_custom_field_values)
          .where(product_id: item.product_id, cart_item_custom_field_values: { id: nil })
          .first

        if existing_item
          existing_item.quantity += item.quantity
          existing_item.save!
          item.destroy!
        else
          item.update!(cart: user_cart)
        end
      end
    end

    # Supprime le guest_cart et le guest_token une fois mergé
    guest_cart.destroy if guest_cart.reload.cart_items.empty?
    session[:guest_token] = nil
  end
end
