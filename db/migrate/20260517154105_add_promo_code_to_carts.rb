class AddPromoCodeToCarts < ActiveRecord::Migration[8.1]
  def change
    add_reference :carts, :promo_code, foreign_key: true
  end
end
