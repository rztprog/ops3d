class ProductsController < ApplicationController
  def index
    @products = Product.visible.includes(:category)
    @canonical_url = products_url(locale: I18n.locale)
    # Rails.logger.info "[IP DEBUG] remote_ip=#{request.remote_ip} ip=#{request.ip} xff=#{request.headers['X-Forwarded-For']}"
  end

  def show
    @product = Product
      .includes(:category, images_attachments: :blob)
      .find(params[:id])

    @custom_fields = @product.product_custom_fields.ordered
  end
end
