module BreadcrumbsHelper
  def breadcrumb_home
    {
      name: "Accueil",
      url: root_url(locale: I18n.locale)
    }
  end

  def breadcrumb_item(name, url = nil)
    {
      name: name,
      url: url
    }
  end

  def breadcrumbs_json_ld(items)
    {
      "@context": "https://schema.org",
      "@type": "BreadcrumbList",
      "itemListElement": items.each_with_index.map do |item, index|
        {
          "@type": "ListItem",
          "position": index + 1,
          "name": item[:name],
          "item": item[:url]
        }.compact
      end
    }
  end
end