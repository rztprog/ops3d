class Product < ApplicationRecord
  belongs_to :category

  has_many :cart_items, dependent: :restrict_with_exception
  has_many_attached :images
  has_many :order_items, dependent: :nullify

  has_many :product_quantity_prices, dependent: :destroy
  accepts_nested_attributes_for :product_quantity_prices,
  allow_destroy: true,
  reject_if: ->(attrs) { attrs["min_quantity"].blank? || attrs["unit_price_cents"].blank? }

  validates :name, presence: true
  validates :price_cents, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :published, inclusion: { in: [ true, false ] }
  validates :available, inclusion: { in: [ true, false ] }

  scope :published, -> { where(published: true) }
  scope :available, -> { where(available: true) }
  scope :visible, -> { where(published: true, available: true) }

  # Objet avec des champs en plus
  has_many :product_custom_fields, dependent: :destroy
  accepts_nested_attributes_for :product_custom_fields,
    allow_destroy: true,
    reject_if: proc { |attrs| attrs["label"].blank? }

  # Stock/Disponibilité
  FULFILLMENT_MODES = %w[made_to_order ready_to_ship].freeze

  validates :fulfillment_mode, presence: true, inclusion: { in: FULFILLMENT_MODES }
  validates :stock_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def made_to_order?
    fulfillment_mode == "made_to_order"
  end

  def ready_to_ship?
    fulfillment_mode == "ready_to_ship"
  end

  def in_stock?
    made_to_order? || stock_quantity.positive?
  end

  def stock_managed?
    ready_to_ship?
  end
end
