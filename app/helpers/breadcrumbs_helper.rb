module BreadcrumbsHelper
  def breadcrumbs_for(product = nil)
    items = [
      {
        name: "Accueil",
        url: root_url(locale: I18n.locale)
      }
    ]

    if product.present?
      items << {
        name: "Produits",
        url: products_url(locale: I18n.locale)
      }

      items << {
        name: product.name,
        url: product_url(product, locale: I18n.locale)
      }
    end

    items
  end
end
