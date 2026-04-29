module Admin
  class UsersController < BaseController
    before_action :set_user, only: [ :show ]

    def index
      @users = User.includes(:orders).order(created_at: :desc)
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
