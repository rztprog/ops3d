# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://ops3d.fr"

# Si le sitemap commence à devenir gros supprimer le compress false
SitemapGenerator::Sitemap.compress = false

SitemapGenerator::Sitemap.public_path = "public/"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end


  %i[fr en].each do |locale|
    add root_path(locale: locale), changefreq: "daily", priority: locale == :fr ? 1.0 : 0.8
    add products_path(locale: locale), changefreq: "daily", priority: 0.9
    add training_path(locale: locale), changefreq: "monthly", priority: 0.7

    Product.where(published: true).find_each do |product|
      add product_path(locale: locale, id: product),
          lastmod: product.updated_at,
          changefreq: "weekly",
          priority: 0.8
    end
  end
end
