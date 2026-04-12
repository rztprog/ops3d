class ProductsController < ApplicationController
  def index
    @products = Product.visible.includes(:category)
  end

  def show
    @product = Product.visible.find(params[:id])
  end
end
