class ProductsController < ApplicationController
  def index
    @products = Product.visible.includes(:category)
  end

  def show
    @product = Product
      .includes(:category, images_attachments: :blob)
      .find(params[:id])

    @custom_fields = @product.product_custom_fields.ordered
  end
end
