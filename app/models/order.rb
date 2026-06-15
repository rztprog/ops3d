class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy

  before_validation do
    self.email = email.to_s.downcase.strip
  end

  STATUSES = %w[
    pending
    paid
    in_preparation
    shipped
    refunded
    cancelled
  ].freeze

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
