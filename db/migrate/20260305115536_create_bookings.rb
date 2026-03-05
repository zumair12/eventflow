class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event, null: false, foreign_key: true
      t.integer :status, null: false, default: 0
      t.string :reference_code, null: false
      t.integer :total_seats, null: false, default: 0
      t.decimal :total_amount, precision: 10, scale: 2, null: false, default: 0

      t.timestamps
    end

    add_index :bookings, :reference_code, unique: true
    add_index :bookings, :status
    add_index :bookings, [:user_id, :event_id]
  end
end
