class CartItemsController < ApplicationController
  def create
    @cart = ensure_cart
    product = Product.find(params[:product_id])

    cart_item = @cart.cart_items.find_by(product: product)

    if cart_item
      cart_item.increment!(:quantity)
    else
      @cart.cart_items.create!(product: product, quantity: 1)
    end

    redirect_to cart_path
  end

  def update
    cart_item = ensure_cart.cart_items.find(params[:id])
    cart_item.update!(quantity: params[:quantity])

    redirect_to cart_path
  end

  def destroy
    cart_item = ensure_cart.cart_items.find(params[:id])
    cart_item.destroy

    redirect_to cart_path
  end
end
