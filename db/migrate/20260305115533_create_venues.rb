class CreateVenues < ActiveRecord::Migration[8.1]
  def change
    create_table :venues do |t|
      t.string :name, null: false
      t.string :address, null: false
      t.string :city, null: false
      t.integer :rows, null: false, default: 10
      t.integer :columns, null: false, default: 10
      t.text :description
      t.string :image_url

      t.timestamps
    end

    add_index :venues, :city
    add_index :venues, :name
  end
end
