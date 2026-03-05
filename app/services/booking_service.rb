# frozen_string_literal: true

# BookingService handles atomic seat reservation and booking creation.
# It prevents race conditions by locking seats within a DB transaction.
class BookingService
  Result = Data.define(:booking, :success, :error)

  def initialize(user:, event:, seats:)
    @user  = user
    @event = event
    @seats = seats
  end

  def call
    booking = nil

    ActiveRecord::Base.transaction do
      # Load & lock seats in one query to prevent double-booking in concurrent requests.
      # Materialise to an Array *before* calling .count so Postgres never sees
      # a FOR UPDATE mixed with an aggregate function.
      locked_seats = Seat.lock.where(id: @seats.map(&:id)).to_a
      validate_seats_availability!(locked_seats)

      seat_count = locked_seats.size
      booking = Booking.create!(
        user: @user,
        event: @event,
        status: :confirmed,
        total_seats: seat_count,
        total_amount: seat_count * @event.price
      )

      locked_seats.each do |seat|
        booking.booking_seats.create!(seat: seat)
      end
    end

    booking
  rescue ActiveRecord::RecordInvalid => e
    build_failed_booking(e.message)
  rescue SeatUnavailableError => e
    build_failed_booking(e.message)
  end

  private

  def validate_seats_availability!(seats)
    booked_ids = Booking.confirmed
                        .where(event: @event)
                        .joins(:booking_seats)
                        .pluck("booking_seats.seat_id")

    unavailable = seats.select { |s| booked_ids.include?(s.id) }
    return if unavailable.empty?

    raise SeatUnavailableError, "Seat(s) #{unavailable.map(&:label).join(', ')} are no longer available"
  end

  def build_failed_booking(error_message)
    booking = Booking.new(user: @user, event: @event)
    booking.errors.add(:base, error_message)
    booking
  end
end

class SeatUnavailableError < StandardError; end
