module Admin
  class DashboardController < BaseController
    def index
      @products_count   = Product.count
      @categories_count = Category.count
      @orders_count     = Order.count
      @users_count      = User.count
    end
  end
end
