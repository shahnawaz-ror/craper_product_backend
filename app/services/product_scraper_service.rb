require "selenium-webdriver"
require "nokogiri"

class ProductScraperService
  attr_reader :product

  def initialize(url)
    @url = url
  end

  def call
    driver = setup_driver

    begin
      driver.navigate.to(@url)
      sleep 3
      html = driver.page_source
      page = Nokogiri::HTML(html)

      parsed_data = parse_page_content(page)
      category = find_or_create_category(parsed_data[:category_name])

      existing_product = Product.find_by(url: @url)
      if existing_product
        update_product(existing_product, parsed_data.merge(category: category))
        @product = existing_product
      else
        @product = create_product(parsed_data.merge(category: category))
      end
    rescue StandardError => e
      Rails.logger.error("Product scraping failed: #{e.message}")
      raise
    ensure
      driver.quit if driver
    end
    self
  end

  private

  def setup_driver
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument("--headless")
    options.add_argument("--disable-gpu")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")

    Selenium::WebDriver.for(:chrome, options: options)
  end

  def parse_page_content(page)
    {
      title: page.at_css("span.VU-ZEz")&.text&.strip || "No title available",
      description: page.css("div.AoD2-N p")&.map(&:text)&.join(" ") || "No description available",
      price: parse_price(page.at_css("div.Nx9bqj")&.text),
      size: page.css("a.CDDksN")&.map(&:text)&.join(", ") || "No size available",
      category_name: parse_category(page) || "Uncategorized"
    }
  end

  def parse_price(price_text)
    return "No price available" unless price_text

    # Strip everything except digits and decimal points
    price_text.gsub(/[^0-9.]/, "").to_f
  end

  def parse_category(page)
    categories = page.css("a.R0cyWM")&.map(&:text)
    categories[1] if categories&.any?
  end

  def find_or_create_category(name)
    Category.find_or_create_by(name: name)
  end

  def create_product(data)
    # Ensure the URL is a valid string
    raise "URL is invalid: #{@url}" unless @url.is_a?(String) && !@url.blank?

    Product.create!(
      title: data[:title],
      description: data[:description],
      price: data[:price],
      size: data[:size],
      scraped_at: Time.now,
      category: data[:category],
      url: @url
    )
  end

  def update_product(product, data)
    product.update!(
      title: data[:title],
      description: data[:description],
      price: data[:price],
      size: data[:size],
      scraped_at: Time.now,
      category: data[:category]
    )
  end
end
