module ApplicationHelper
  def order_status_label(status)
    case status
    when "pending"
      "En attente"
    when "paid"
      "Payée"
    when "in_preparation"
      "En préparation"
    when "shipped"
      "Expédiée"
    when "cancelled"
      "Annulée"
    else
      status.to_s.humanize
    end
  end
end
