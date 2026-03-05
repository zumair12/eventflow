class CreateSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :seats do |t|
      t.references :venue, null: false, foreign_key: true
      t.integer :row, null: false
      t.integer :column, null: false
      t.string :label, null: false
      t.integer :seat_type, null: false, default: 0
      t.boolean :available, null: false, default: true

      t.timestamps
    end

    add_index :seats, [:venue_id, :row, :column], unique: true
    add_index :seats, :seat_type
    add_index :seats, :available
  end
end
