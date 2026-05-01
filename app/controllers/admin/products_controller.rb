module Admin
  class ProductsController < BaseController
    before_action :set_product, only: [ :show, :edit, :update, :destroy ]

    def index
      @products = Product.includes(:category, images_attachments: :blob).order(created_at: :desc)
    end

    def show
    end

    def new
      @product = Product.new
      5.times { @product.product_custom_fields.build }
    end

    def create
      @product = Product.new(product_params)

      if @product.save
        redirect_to admin_products_path, notice: "Produit créé avec succès."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      (5 - @product.product_custom_fields.size).times { @product.product_custom_fields.build }
    end

    def update
      if @product.update(product_params)
        redirect_to admin_products_path, notice: "Produit mis à jour avec succès."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: "Produit supprimé avec succès."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def product_params
    params.require(:product).permit(
      :name,
      :description,
      :price_euros,
      :category_id,
      :published,
      :available,
      images: [],
      product_custom_fields_attributes: [
        :id,
        :label,
        :field_type,
        :required,
        :position,
        :placeholder,
        :_destroy
      ]
    )
    end
  end
end
