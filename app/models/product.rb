class Product < ApplicationRecord
  belongs_to :category

  has_many :cart_items, dependent: :restrict_with_exception
  has_many_attached :images
  has_many :order_items, dependent: :nullify

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
end
