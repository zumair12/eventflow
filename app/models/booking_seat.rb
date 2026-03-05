# frozen_string_literal: true

class BookingSeat < ApplicationRecord
  belongs_to :booking
  belongs_to :seat

  validates :booking_id, uniqueness: { scope: :seat_id, message: "seat already selected for this booking" }
  validate :seat_not_already_booked

  private

  def seat_not_already_booked
    return unless seat && booking
    if seat.booked_for?(booking.event)
      errors.add(:seat, "#{seat.label} is already booked for this event")
    end
  end
end
