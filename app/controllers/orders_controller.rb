class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_cart_present, only: [ :new, :create ]
  before_action :set_order, only: [ :show ]

  def index
    @orders = current_user.orders.order(created_at: :desc)
  end

  def new
    @cart = ensure_cart
    @cart_items = @cart.cart_items.includes(:product)

    @subtotal_cents = cart_subtotal_cents(@cart_items)
    @shipping_cents = current_shipping_cents
    @total_cents = @subtotal_cents + @shipping_cents

    @order = current_user.orders.new(
      email: current_user.email,
      first_name: current_user.first_name,
      last_name: current_user.last_name
    )
  end

  def create
    @cart = ensure_cart
    @cart_items = @cart.cart_items.includes(
      :product,
      cart_item_custom_field_values: :product_custom_field
    )

    @subtotal_cents = cart_subtotal_cents(@cart_items)
    @shipping_cents = current_shipping_cents
    @total_cents = @subtotal_cents + @shipping_cents

    @order = current_user.orders.new(order_params)
    @order.email = current_user.email
    @order.status = "pending"
    @order.subtotal_price_cents = @subtotal_cents
    @order.shipping_price_cents = @shipping_cents
    @order.shipping_mode = current_shipping_mode
    @order.total_price_cents = @total_cents

    ActiveRecord::Base.transaction do
      @order.save!

      @cart_items.each do |item|
        customizations = item.cart_item_custom_field_values
          .includes(:product_custom_field)
          .each_with_object({}) do |custom_value, hash|
            hash[custom_value.product_custom_field.label] = custom_value.value
          end

        @order.order_items.create!(
          product: item.product,
          product_name: item.product.name,
          quantity: item.quantity,
          unit_price_cents: item.product.price_cents,
          customizations: customizations
        )
      end

      @cart.cart_items.destroy_all
    end

    redirect_to order_path(@order), notice: "Commande créée avec succès."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  def show
    redirect_to root_path, alert: "Accès non autorisé." unless @order.user == current_user
  end

  def checkout
    # Guard pour ne pas repayée une commande
    unless @order.status == "pending"
      redirect_to order_path(@order), alert: "Cette commande ne peut plus être payée."
      return
    end

    @order = current_user.orders.find(params[:id])

    session = Stripe::Checkout::Session.create(
      customer_email: @order.email,

      metadata: {
        order_id: @order.id,
        user_id: @order.user_id
      },

      payment_intent_data: {
        metadata: {
          order_id: @order.id,
          user_id: @order.user_id
        }
      },

      payment_method_types: [ "card" ],
      line_items: @order.order_items.map do |item|
        {
          price_data: {
            currency: "eur",
            product_data: {
              name: item.product_name
            },
            unit_amount: item.unit_price_cents
          },
          quantity: item.quantity
        }
      end,
      mode: "payment",
      success_url: order_url(@order),
      cancel_url: cart_url
    )

    @order.update!(stripe_checkout_session_id: session.id)

    redirect_to session.url, allow_other_host: true
  end

  private

  def set_order
    @order = Order.includes(:order_items).find(params[:id])
  end

  def order_params
    params.require(:order).permit(
      :first_name,
      :last_name,
      :address_line,
      :address_line2,
      :city,
      :postal_code,
      :country
    )
  end

  def ensure_cart_present
    cart = current_cart
    return if cart.present? && cart.cart_items.any?

    redirect_to cart_path, alert: "Ton panier est vide."
  end

  def cart_subtotal_cents(cart_items)
    cart_items.sum { |item| item.quantity * item.product.price_cents }
  end

  def current_shipping_mode
    Ops3dSetting.first&.shipping_mode || "free"
  end

  def current_shipping_cents
    settings = Ops3dSetting.first
    return 0 unless settings

    settings.shipping_mode == "flat_rate" ? settings.shipping_price_cents : 0
  end
end
