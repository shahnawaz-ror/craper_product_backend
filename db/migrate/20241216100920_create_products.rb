class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :title
      t.text :description
      t.decimal :price
      t.string :size
      t.references :category, null: false, foreign_key: true
      t.datetime :scraped_at

      t.timestamps
    end
  end
end
