class PagesController < ApplicationController
  def home
    @featured_products = Product.visible
                                .includes(:category, images_attachments: :blob)
                                .limit(4)
  end

  def current_cart
    if user_signed_in?
      current_user.cart || current_user.create_cart
    else
      Cart.find_or_create_by(guest_token: session[:guest_token])
    end
  end

  def legal; end
  def terms; end
  def faq; end
  def contact; end
  def about; end
end
