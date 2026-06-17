class ExportOrderToGoogleSheetsJob < ApplicationJob
  queue_as :default

  def perform(order_id)
    order = Order.includes(:order_items).find(order_id)

    return unless order.status == "paid"

    GoogleSheetsOrderExporter.new(order).call
  end
end
