require 'rails_helper'

RSpec.describe Api::V1::CategoriesController, type: :controller do
  describe "GET #index" do
    let!(:categories) { create_list(:category, 3) }

    it "returns all categories as JSON" do
      get :index

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response.size).to eq(categories.size)
    end
  end

  describe "GET #show" do
    let!(:category) { create(:category) }

    context "when the category exists" do
      it "returns the category as JSON" do
        get :show, params: { id: category.id }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response["id"]).to eq(category.id)
        expect(json_response["name"]).to eq(category.name)
      end
    end

    context "when the category does not exist" do
      it "returns a 404 not found status" do
        get :show, params: { id: 999 } # Non-existent ID

        expect(response).to have_http_status(:not_found)
        expect(JSON.parse(response.body)).to eq({ "error" => "Category not found" })
      end
    end
  end
end
