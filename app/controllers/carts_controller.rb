class CartsController < ApplicationController
  def show
    @cart = current_cart || ensure_cart

    @cart_items = @cart.cart_items.includes(
      { product: { images_attachments: :blob } },
      { cart_item_custom_field_values: :product_custom_field }
    )

    @applied_promo = @cart.promo_code

    @subtotal_cents = @cart_items.sum { |item| item.quantity * item.product.price_cents }

    settings = Ops3dSetting.first
    @shipping_cents =
      if settings&.shipping_mode == "flat_rate"
        settings.shipping_price_cents
      else
        0
      end

    @discount_cents =
      if @applied_promo&.active?
        [ @applied_promo.discount_cents, @subtotal_cents ].min
      else
        0
      end

    @total_cents = @subtotal_cents + @shipping_cents - @discount_cents
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
