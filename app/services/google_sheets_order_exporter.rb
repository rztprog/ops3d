require "google/apis/sheets_v4"
require "googleauth"

class GoogleSheetsOrderExporter
  RANGE = "Horodateur!A:N"

  def initialize(order)
    @order = order
  end

  def call
    service.append_spreadsheet_value(
      spreadsheet_id,
      RANGE,
      value_range,
      value_input_option: "USER_ENTERED"
    )
  end

  private

  attr_reader :order

  def service
    @service ||= begin
      sheets = Google::Apis::SheetsV4::SheetsService.new
      sheets.authorization = credentials
      sheets
    end
  end

  def credentials
    json = JSON.parse(ENV.fetch("GOOGLE_SHEETS_PRIVATE_KEY_JSON"))

    json["private_key"] = json["private_key"].gsub("\\n", "\n")

    Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: StringIO.new(json.to_json),
      scope: Google::Apis::SheetsV4::AUTH_SPREADSHEETS
    )
  end

  def spreadsheet_id
    ENV.fetch("GOOGLE_SHEETS_SPREADSHEET_ID")
  end

  def value_range
    Google::Apis::SheetsV4::ValueRange.new(
      values: [
        [
          I18n.l(order.created_at, format: :short),
          order.id,
          "#{order.first_name} #{order.last_name}",
          order.email,
          order.order_items.map { |item| "#{item.product_name} x#{item.quantity}" }.join(", "),
          order.payment_provider,
          order.status,
          order.total_price_cents / 100.0
        ]
      ]
    )
  end
end