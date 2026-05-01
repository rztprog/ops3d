class CartItemCustomFieldValue < ApplicationRecord
  belongs_to :cart_item
  belongs_to :product_custom_field
end
