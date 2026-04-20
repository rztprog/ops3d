class AccountsController < ApplicationController
  before_action :authenticate_user!

  def show
    @orders = current_user.orders.order(created_at: :desc).limit(5)
  end
end
