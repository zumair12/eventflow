class CreateBookingSeats < ActiveRecord::Migration[8.1]
  def change
    create_table :booking_seats do |t|
      t.references :booking, null: false, foreign_key: true
      t.references :seat, null: false, foreign_key: true

      t.timestamps
    end

    add_index :booking_seats, [:booking_id, :seat_id], unique: true
  end
end
