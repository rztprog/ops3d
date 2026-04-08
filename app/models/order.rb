class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy

  STATUSES = %w[pending paid in_preparation shipped cancelled].freeze

  validates :status, presence: true, inclusion: { in: STATUSES }

  validates :subtotal_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :shipping_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }

  validates :shipping_mode, presence: true
  validates :email, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :address_line, presence: true
  validates :city, presence: true
  validates :postal_code, presence: true
  validates :country, presence: true
end
