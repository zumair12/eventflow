# frozen_string_literal: true

require "rails_helper"

RSpec.describe BookingService do
  let(:venue)     { create(:venue, rows: 3, columns: 4) }
  let(:organizer) { create(:user, :organizer) }
  let(:event)     { create(:event, :published, venue: venue, organizer: organizer, capacity: 10, price: 25.00) }
  let(:user)      { create(:user) }
  let(:seats)     { venue.seats.first(2) }

  subject(:service) { described_class.new(user: user, event: event, seats: seats) }

  describe "#call" do
    context "when seats are available" do
      it "creates a confirmed booking" do
        booking = service.call
        expect(booking).to be_persisted
        expect(booking.status).to eq("confirmed")
      end

      it "assigns the correct user and event" do
        booking = service.call
        expect(booking.user).to eq(user)
        expect(booking.event).to eq(event)
      end

      it "records the correct seat count" do
        booking = service.call
        expect(booking.total_seats).to eq(2)
      end

      it "calculates total_amount as seats × price" do
        booking = service.call
        expect(booking.total_amount).to eq(50.00)
      end

      it "creates BookingSeat join records" do
        booking = service.call
        expect(booking.seats.count).to eq(2)
        expect(booking.seats).to match_array(seats)
      end

      it "generates a reference code" do
        booking = service.call
        expect(booking.reference_code).to match(/\AEF-[A-Z0-9]{8}\z/)
      end
    end

    context "when a seat is already booked" do
      before do
        # Simulate another booking taking those seats
        prior_booking = create(:booking, :confirmed, user: create(:user), event: event,
                               reference_code: "EF-PRIOR001", total_seats: 2)
        seats.each { |s| create(:booking_seat, booking: prior_booking, seat: s) }
      end

      it "returns an unpersisted booking with an error" do
        booking = service.call
        expect(booking).not_to be_persisted
        expect(booking.errors[:base]).to be_present
      end

      it "does not create any BookingSeat records for the failed booking" do
        expect { service.call }.not_to change(BookingSeat, :count)
      end
    end

    context "with a free event" do
      let(:event) { create(:event, :published, :free, venue: venue, organizer: organizer, capacity: 10) }

      it "sets total_amount to zero" do
        booking = service.call
        expect(booking.total_amount).to eq(0)
      end
    end
  end
end
