class CartItemCustomFieldValue < ApplicationRecord
  belongs_to :cart_item
  belongs_to :product_custom_field

  validates :product_custom_field_id, uniqueness: { scope: :cart_item_id }
end
