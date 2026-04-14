class CartsController < ApplicationController
  def show
    @cart = current_cart || ensure_cart
    @cart_items = @cart.cart_items.includes(product: [ images_attachments: :blob ])

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
end
