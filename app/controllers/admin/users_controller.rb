module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :show ]

    def index
      users = User.includes(:orders).order(created_at: :desc)

      registered_customers = users.map do |user|
        OpenStruct.new(
          guest?: false,
          admin?: user.admin?,
          first_name: user.first_name,
          last_name: user.last_name,
          email: user.email,
          created_at: user.created_at,
          orders_count: user.orders.size,
          path: admin_user_path(user)
        )
      end

      guest_customers = Order
        .where(user_id: nil)
        .where.not(email: [ nil, "" ])
        .group_by { |order| order.email.downcase.strip }
        .map do |_email, orders|
          latest_order = orders.max_by(&:created_at)

          OpenStruct.new(
            guest?: true,
            admin?: false,
            first_name: latest_order.first_name,
            last_name: latest_order.last_name,
            email: latest_order.email,
            created_at: latest_order.created_at,
            orders_count: orders.size,
            path: admin_order_path(latest_order)
          )
        end

      @customers = (registered_customers + guest_customers)
        .sort_by(&:created_at)
        .reverse
    end

    def show
      @orders = @user.orders.order(created_at: :desc)
    end

    private

    def set_user
      @user = User.find(params[:id])
    end
  end
end
