module Admin
  class DashboardController < BaseController
    SALES_STATUSES = %w[paid in_preparation shipped].freeze
    PROCESSING_STATUSES = %w[paid].freeze

    def index
      @products_count   = Product.count
      @categories_count = Category.count
      @orders_count     = Order.count
      @users_count      = User.count

      sales_orders = Order.where(status: SALES_STATUSES)
      orders_to_process = Order.where(status: PROCESSING_STATUSES)

      @today_revenue_cents = sales_orders
        .where(created_at: Time.current.all_day)
        .sum(:total_price_cents)

      @week_revenue_cents = sales_orders
        .where(created_at: 6.days.ago.beginning_of_day..Time.current)
        .sum(:total_price_cents)

      @paid_orders_count = sales_orders.count
      @orders_to_process_count = orders_to_process.count

      @recent_orders = Order
        .includes(:user, :order_items)
        .order(created_at: :desc)
        .limit(5)

      @sales_by_day = (6.days.ago.to_date..Date.current).map do |date|
        total_cents = sales_orders
          .where(created_at: date.all_day)
          .sum(:total_price_cents)

        {
          date: date,
          label: I18n.l(date, format: :short),
          total_cents: total_cents
        }
      end

      @max_sales_cents = @sales_by_day
        .map { |day| day[:total_cents] }
        .max
        .to_i
    end
  end
end
