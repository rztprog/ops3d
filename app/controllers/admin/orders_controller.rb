module Admin
  class OrdersController < BaseController
    before_action :set_order, only: [ :show, :update ]

    def index
      @orders = Order.includes(:user, :order_items).order(created_at: :desc)
    end

    def show
    end

    def update
      attrs = order_params.to_h

      if order_params[:status] == "shipped" &&
        @order.tracking_number.blank? &&
        order_params[:tracking_number].blank?

        redirect_to admin_order_path(@order),
          alert: "Ajoute un numéro de suivi avant de marquer la commande comme expédiée."
        return
      end

      if attrs[:status] == "refunded" && @order.refunded_at.blank?
        attrs[:refunded_at] = Time.current
      end

      previous_status = @order.status

      if @order.update(attrs)
        if @order.status == "shipped" && @order.shipped_at.blank?
          @order.update_column(:shipped_at, Time.current)
        end

        if previous_status != @order.status
          if @order.status == "in_preparation"
            OrderMailer.with(order: @order).in_preparation.deliver_later
          elsif @order.status == "shipped"
            OrderMailer.with(order: @order).shipped.deliver_later
          end
        end
        redirect_to admin_order_path(@order), notice: "Statut de la commande mis à jour."
      else
        redirect_to admin_order_path(@order), alert: "Impossible de mettre à jour la commande."
      end
    end

    private

    def set_order
      @order = Order.includes(order_items: :product).find(params[:id])
    end

    def order_params
      params.require(:order).permit(:status, :refund_reason, :tracking_number)
    end
  end
end
