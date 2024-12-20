class UpdateProductJob < ApplicationJob
  queue_as :default

  def perform(product_id)
    product = Product.find(product_id)

    if product.url.blank? || !product.url.is_a?(String)
      Rails.logger.error("Invalid URL for product ID #{product_id}: #{product.url.inspect}")
      return
    end

    return unless product.scraped_at < 1.week.ago

    scraper = ProductScraperService.new(product.url)
    scraper.call
  rescue ActiveRecord::RecordNotFound
    Rails.logger.warn("Product with ID #{product_id} not found for update.")
  rescue StandardError => e
    Rails.logger.error("Failed to update product: #{e.message}")
  end
end
