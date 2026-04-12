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
end
