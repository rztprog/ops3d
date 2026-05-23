class CartsController < ApplicationController
  def show
    @cart = current_cart || ensure_cart

    @promo_code = PromoCode.new
    @applied_promo = @cart.promo_code

    @cart_items = @cart.cart_items.includes(
      { product: { images_attachments: :blob } },
      { cart_item_custom_field_values: :product_custom_field }
    )

    @subtotal_cents = @cart.subtotal_cents
    @shipping_cents = @cart.shipping_cents
    @discount_cents = @cart.discount_cents

    @total_cents = @cart.total_cents
  end

  def apply_promo_code
    @cart = current_cart || ensure_cart

    promo = PromoCode.active.find_by(
      code: params[:code].to_s.strip.upcase
    )

    if promo.present?
      @cart.update!(promo_code: promo)
      redirect_to cart_path, notice: "Code promo appliqué."
    else
      redirect_to cart_path, alert: "Code promo invalide."
    end
  end

  def remove_promo_code
    @cart = current_cart || ensure_cart
    @cart.update!(promo_code: nil)

    redirect_to cart_path, notice: "Code promo retiré."
  end
end
