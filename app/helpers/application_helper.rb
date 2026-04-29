module ApplicationHelper
  def order_status_label(status)
    t("orders.statuses.#{status}", default: status.to_s.humanize)
  end

  def order_status_badge_class(status)
    case status
    when "pending"
      "bg-yellow-100 text-yellow-800"
    when "paid"
      "bg-blue-100 text-blue-800"
    when "in_preparation"
      "bg-lime-100 text-lime-800"
    when "shipped"
      "bg-green-100 text-green-800"
    when "cancelled"
      "bg-red-100 text-red-800"
    else
      "bg-gray-100 text-gray-700"
    end
  end
end
