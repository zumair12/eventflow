# frozen_string_literal: true

class Venue < ApplicationRecord
  has_many :seats, dependent: :destroy
  has_many :events, dependent: :nullify

  validates :name, presence: true, length: { maximum: 100 }
  validates :address, presence: true
  validates :city, presence: true
  validates :rows, :columns, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 50 }

  after_create :generate_seats

  def total_capacity
    rows * columns
  end

  def available_seats_for(event)
    booked_seat_ids = event.bookings.confirmed.joins(:booking_seats).pluck("booking_seats.seat_id")
    seats.where.not(id: booked_seat_ids)
  end

  private

  def generate_seats
    rows.times do |row|
      columns.times do |col|
        label = "#{('A'.ord + row).chr}#{col + 1}"
        seats.create!(
          row: row + 1,
          column: col + 1,
          label: label,
          seat_type: :standard,
          available: true
        )
      end
    end
  end
end
