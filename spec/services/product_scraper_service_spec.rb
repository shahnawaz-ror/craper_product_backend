require 'rails_helper'
require 'selenium-webdriver'
require 'nokogiri'

RSpec.describe ProductScraperService do
  let(:url) { 'https://example.com/product' }
  let(:service) { described_class.new(url) }

  describe '#call' do
    let(:driver) { instance_double(Selenium::WebDriver::Driver) }
    let(:page_source) { '<html><span class="VU-ZEz">Product Title</span></html>' }
    let(:page) { Nokogiri::HTML(page_source) }
    let(:category) { create(:category, name: 'Sample Category') }

    before do
      allow(service).to receive(:setup_driver).and_return(driver)
      allow(driver).to receive_message_chain(:navigate, :to).with(url)
      allow(driver).to receive(:page_source).and_return(page_source)
      allow(driver).to receive(:quit) # Add this line
      allow(Nokogiri::HTML).to receive(:parse).with(page_source).and_return(page)
      allow(Category).to receive(:find_or_create_by).with(name: 'Uncategorized').and_return(category)
    end

    after { allow(driver).to receive(:quit) }

    context 'when the product does not exist' do
      it 'creates a new product' do
        expect {
          service.call
        }.to change(Product, :count).by(1)

        product = Product.last
        expect(product.title).to eq('Product Title')
        expect(product.category).to eq(category)
      end
    end

    context 'when the product already exists' do
      let!(:existing_product) { create(:product, url: url, category: category) }

      it 'updates the existing product' do
        service.call
        existing_product.reload

        expect(existing_product.title).to eq('Product Title')
        expect(existing_product.scraped_at).to be_within(1.second).of(Time.now)
      end
    end

    context 'when scraping fails' do
      before do
        allow(driver).to receive_message_chain(:navigate, :to).and_raise(StandardError, 'Scraping error')
      end

      it 'logs an error and raises an exception' do
        expect(Rails.logger).to receive(:error).with(/Product scraping failed: Scraping error/)
        expect { service.call }.to raise_error(StandardError, 'Scraping error')
      end
    end
  end

  describe '#setup_driver' do
    it 'returns a Selenium WebDriver instance' do
      driver = service.send(:setup_driver)
      expect(driver).to be_a(Selenium::WebDriver::Driver)
    end
  end

  describe '#parse_price' do
    it 'returns a float representation of the price' do
      expect(service.send(:parse_price, '$123.45')).to eq(123.45)
    end

    it 'returns a default message for invalid price' do
      expect(service.send(:parse_price, nil)).to eq('No price available')
    end
  end

  describe '#find_or_create_category' do
    it 'finds an existing category by name' do
      category = create(:category, name: 'Electronics')
      expect(service.send(:find_or_create_category, 'Electronics')).to eq(category)
    end

    it 'creates a new category if not found' do
      expect {
        service.send(:find_or_create_category, 'Toys')
      }.to change(Category, :count).by(1)

      expect(Category.last.name).to eq('Toys')
    end
  end
end
