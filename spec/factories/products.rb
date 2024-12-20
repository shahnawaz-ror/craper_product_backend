FactoryBot.define do
  factory :product do
    title { "Sample Product" }
    description { "Sample Description" }
    price { 100.0 }
    size { "M" }
    scraped_at { Time.now }
    association :category
  end
end
