class CartItemsController < ApplicationController
  def create
    @product = Product.find(params[:product_id])

    # Guard pour requete forgée
    if @product.product_custom_fields.exists? && !user_signed_in?
      redirect_to new_user_session_path, alert: "Connecte-toi pour commander ce produit personnalisé."
      return
    end

    @cart = ensure_cart

    custom_fields = @product.product_custom_fields.ordered
    custom_values = params[:custom_fields] || {}

    missing_required_fields = custom_fields.select do |field|
      field.required? && custom_values[field.id.to_s].blank?
    end

    if missing_required_fields.any?
      redirect_to product_path(@product), alert: "Merci de renseigner tous les champs obligatoires."
      return
    end

    if custom_fields.any?
      cart_item = @cart.cart_items.create!(
        product: @product,
        quantity: 1
      )

      custom_fields.each do |field|
        value = custom_values[field.id.to_s]

        next if value.blank? && !field.required?

        cart_item.cart_item_custom_field_values.create!(
          product_custom_field: field,
          value: value
        )
      end
    else
      cart_item = @cart.cart_items.find_or_initialize_by(product: @product)
      cart_item.quantity += 1
      cart_item.save!
    end

    redirect_to cart_path, notice: "Produit ajouté au panier."
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
