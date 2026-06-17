class ExportOrderToGoogleSheetsJob < ApplicationJob
  queue_as :default

  EXPORTABLE_STATUSES = %w[paid in_preparation shipped].freeze

  def perform(order_id)
    order = Order.includes(:order_items).find(order_id)

    return unless order.status.in?(EXPORTABLE_STATUSES)
    return if order.google_sheets_exported_at.present?

    Order.transaction do
      order.lock!
      return if order.google_sheets_exported_at.present?

      GoogleSheetsOrderExporter.new(order).call

      order.update!(google_sheets_exported_at: Time.current)
    end
  end
end