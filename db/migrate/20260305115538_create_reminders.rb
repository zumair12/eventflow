class CreateReminders < ActiveRecord::Migration[8.1]
  def change
    create_table :reminders do |t|
      t.references :booking, null: false, foreign_key: true
      t.datetime :remind_at, null: false
      t.boolean :sent, null: false, default: false
      t.integer :reminder_type, null: false, default: 0

      t.timestamps
    end

    add_index :reminders, :remind_at
    add_index :reminders, :sent
  end
end
