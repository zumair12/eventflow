# frozen_string_literal: true

class Seat < ApplicationRecord
  belongs_to :venue

  enum :seat_type, { standard: 0, vip: 1, accessible: 2 }, prefix: true

  has_many :booking_seats, dependent: :destroy
  has_many :bookings, through: :booking_seats

  validates :row, :column, presence: true, numericality: { greater_than: 0 }
  validates :label, presence: true, uniqueness: { scope: :venue_id }
  validates :seat_type, presence: true

  scope :available, -> { where(available: true) }
  scope :vip, -> { where(seat_type: :vip) }
  scope :standard, -> { where(seat_type: :standard) }
  scope :accessible, -> { where(seat_type: :accessible) }

  def booked_for?(event)
    bookings.confirmed.exists?(event: event)
  end

  def status_for(event)
    booked_for?(event) ? :booked : :available
  end
end
