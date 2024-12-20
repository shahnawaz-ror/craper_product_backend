class Api::V1::ProductsController < ApplicationController
  def index
    @products = Product.all

    @products.each do |product|
      UpdateProductJob.perform_later(product.id) if product.scraped_at < 1.week.ago
    end

    render json: @products
  end

  def show
    @product = Product.find(params[:id])

    UpdateProductJob.perform_later(@product.id) if @product.scraped_at < 1.week.ago

    render json: @product
  end

  def create
    url = params[:url]
    scraper = ProductScraperService.new(url)
    result = scraper.call
    render json: {
      message: "Product scraped and stored successfully.",
      product: result.product
    }, status: :ok
  end
end
