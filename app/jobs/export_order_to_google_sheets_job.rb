class ExportOrderToGoogleSheetsJob < ApplicationJob
  queue_as :default

  EXPORTABLE_STATUSES = %w[paid in_preparation shipped].freeze

  def perform(order_id)
    order = Order.includes(:order_items).find(order_id)

    return unless order.status.in?(EXPORTABLE_STATUSES)
    return if order.google_sheets_exported_at.present?
    return unless rio_order?(order)

    Order.transaction do
      order.lock!

      return if order.google_sheets_exported_at.present?
      return unless rio_order?(order)

      GoogleSheetsOrderExporter.new(order).call

      order.update!(google_sheets_exported_at: Time.current)
    end
  end

  private

  def rio_order?(order)
    rio_product_id = ENV.fetch("RIO_PRODUCT_ID").to_i

    order.order_items.any? do |item|
      item.product_id == rio_product_id
    end
  end
end
