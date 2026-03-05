class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :title, null: false
      t.text :description
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.integer :status, null: false, default: 0
      t.integer :capacity, null: false, default: 0
      t.decimal :price, precision: 10, scale: 2, null: false, default: 0
      t.string :category
      t.string :image_url
      t.string :location_note
      t.references :venue, null: false, foreign_key: true
      t.references :organizer, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :events, :status
    add_index :events, :start_at
    add_index :events, :category
  end
end
