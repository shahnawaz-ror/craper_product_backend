require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  let!(:product) { create(:product, scraped_at: 2.weeks.ago) }
  let(:url) { 'https://example.com/product' }

  describe "GET #index" do
    it "returns all products as JSON" do
      get :index
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(Product.count)
    end

    it "enqueues UpdateProductJob for products older than 1 week" do
      allow(UpdateProductJob).to receive(:perform_later)

      get :index

      Product.all.each do |product|
        if product.scraped_at < 1.week.ago
          expect(UpdateProductJob).to have_received(:perform_later).with(product.id)
        end
      end
    end
  end

  describe "GET #show" do
    it "returns the requested product as JSON" do
      get :show, params: { id: product.id }
      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['id']).to eq(product.id)
    end

    it "enqueues UpdateProductJob if the product is older than 1 week" do
      allow(UpdateProductJob).to receive(:perform_later)

      get :show, params: { id: product.id }

      expect(UpdateProductJob).to have_received(:perform_later).with(product.id) if product.scraped_at < 1.week.ago
    end
  end

  describe "POST #create" do
    it "scrapes and creates a new product" do
      service = instance_double(ProductScraperService)
      scraped_product = create(:product)

      allow(ProductScraperService).to receive(:new).with(url).and_return(service)
      allow(service).to receive(:call).and_return(double(product: scraped_product))

      post :create, params: { url: url }

      expect(response).to have_http_status(:ok)
      parsed_response = JSON.parse(response.body)
      expect(parsed_response['message']).to eq("Product scraped and stored successfully.")
      expect(parsed_response['product']['id']).to eq(scraped_product.id)
    end
  end
end
