require "google/apis/sheets_v4"
require "googleauth"

class GoogleSheetsOrderExporter
  RANGE = "Réponses au formulaire 1!A:N"

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
    item = order.order_items.find { |i| i.product_id == ENV.fetch("RIO_PRODUCT_ID").to_i }
    customizations = item&.customizations || {}

    Google::Apis::SheetsV4::ValueRange.new(
      values: [
        [
          "(OPS3D) #{I18n.l(order.created_at, format: :short)}",
          order.email,
          order.first_name,
          order.last_name,
          customizations["Votre numéro RIO à 7 chiffres"],
          customizations["Nombre d'exemplaires RIO souhaités"],
          customizations["Numéro de téléphone"],
          customizations["Service / Unité"],
          if order.payment_provider?
            order.payment_provider == "paypal" ? "Oui (Paypal)" : "Oui (Stripe)"
          else
            "Non"
          end,
          customizations["Commentaire ou demande spécifique"] ? customizations["Commentaire ou demande spécifique"] : "",
          "",
          customizations["Nigend"],
          "#{order.address_line} #{order.address_line2 ? order.address_line2 : ""}, #{order.city} #{order.postal_code}",
          ""
        ]
      ]
    )
  end
end
