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

    quantity = params[:cart_item][:quantity].to_i

    if quantity <= 0
      cart_item.destroy
    else
      cart_item.update!(quantity: quantity)
    end

    redirect_to cart_path, notice: "Panier mis à jour."
  end

  def destroy
    cart_item = ensure_cart.cart_items.find(params[:id])
    cart_item.destroy

    redirect_to cart_path, notice: "Produit supprimé du panier."
  end
end
