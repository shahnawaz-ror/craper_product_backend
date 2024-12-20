class AddUrlToProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :products, :url, :string
    add_index :products, :url, unique: true
  end
end
