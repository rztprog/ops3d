class ProductCustomField < ApplicationRecord
  FIELD_TYPES = %w[text textarea number checkbox].freeze

  belongs_to :product

  validates :label, presence: true
  validates :field_type, presence: true, inclusion: { in: FIELD_TYPES }
  validates :position, numericality: { greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:position, :id) }
end
