module ProductsHelper
  def product_availability_label(product)
    if product.ready_to_ship?
      product.stock_quantity.positive? ? "Prêt à expédier" : "Rupture"
    else
      "Sur commande"
    end
  end

  def product_availability_badge_class(product)
    if product.ready_to_ship?
      product.stock_quantity.positive? ?
        "bg-green-50 text-green-700 border-green-200" :
        "bg-red-50 text-red-700 border-red-200"
    else
      "bg-white/90 text-gray-700 border-gray-200"
    end
  end
end
