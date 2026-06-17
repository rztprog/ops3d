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
      7.times { @product.product_custom_fields.build }
      3.times { @product.product_quantity_prices.build }
    end

    def create
      attrs = normalize_quantity_prices_attributes(product_params.except(:price_euros))
      @product = Product.new(attrs)
      @product.price_cents = euros_to_cents(product_params[:price_euros])

      if @product.save
        redirect_to admin_products_path, notice: "Produit créé avec succès."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      (7 - @product.product_custom_fields.size).times { @product.product_custom_fields.build }

      (3 - @product.product_quantity_prices.size).times do
        @product.product_quantity_prices.build
      end
    end

    def update
      attrs = normalize_quantity_prices_attributes(product_params.except(:price_euros))
      attrs[:price_cents] = euros_to_cents(product_params[:price_euros])

      if @product.update(attrs)
        if product_params[:images].present?
          @product.images.attach(product_params[:images])
        end

        redirect_to admin_products_path, notice: "Produit mis à jour avec succès."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @product.destroy
      redirect_to admin_products_path, notice: "Produit supprimé avec succès."
    end

    def remove_image
      @product = Product.find(params[:id])
      image = @product.images.find(params[:image_id])

      image.purge

      redirect_to edit_admin_product_path(@product),
        notice: "Image supprimée."
    end

    private

    def set_product
      @product = Product.find(params[:id])
    end

    def normalize_quantity_prices_attributes(attrs)
      return attrs unless attrs[:product_quantity_prices_attributes].present?

      attrs[:product_quantity_prices_attributes].each do |_index, tier_attrs|
        unit_price_euros = tier_attrs.delete(:unit_price_euros)

        next if unit_price_euros.blank?

        tier_attrs[:unit_price_cents] = euros_to_cents(unit_price_euros)
      end

      attrs
    end

    def product_params
    params.require(:product).permit(
      :name,
      :description,
      :price_euros,
      :category_id,
      :published,
      :available,
      :fulfillment_mode,
      :stock_quantity,
      images: [],
        product_quantity_prices_attributes: [
        :id,
        :min_quantity,
        :unit_price_cents,
        :unit_price_euros,
        :_destroy
      ],
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

    def euros_to_cents(value)
      return nil if value.blank?

      (BigDecimal(value.to_s.tr(",", ".")) * 100).to_i
    end
  end
end
