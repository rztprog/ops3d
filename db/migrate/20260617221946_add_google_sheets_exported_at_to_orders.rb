class AddGoogleSheetsExportedAtToOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :orders, :google_sheets_exported_at, :datetime
  end
end
