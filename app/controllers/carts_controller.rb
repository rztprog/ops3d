class CartsController < ApplicationController
  def show
    @promo_code = PromoCode.new

    @cart = current_cart || ensure_cart
    @applied_promo = @cart.promo_code

    @cart_items = @cart.cart_items.includes(
      { product: { images_attachments: :blob } },
      { cart_item_custom_field_values: :product_custom_field }
    )

    @subtotal_cents = @cart_items.sum { |item| item.quantity * item.product.price_cents }

    settings = Ops3dSetting.first
    @shipping_cents =
      if settings&.shipping_mode == "flat_rate"
        settings.shipping_price_cents
      else
        0
      end

    @total_cents = @subtotal_cents + @shipping_cents
  end

  def apply_promo_code
    @cart = current_cart

    promo = PromoCode.find_by(
      code: params[:code].to_s.strip.upcase
    )

    if promo.present?
      @cart.update!(promo_code: promo)

      redirect_to cart_path,
        notice: "Code promo appliqué."
    else
      redirect_to cart_path,
        alert: "Code promo invalide."
    end
  end
end
