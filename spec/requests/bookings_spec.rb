# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Bookings", type: :request do
  let(:venue)     { create(:venue, rows: 3, columns: 4) }
  let(:organizer) { create(:user, :organizer) }
  let(:attendee)  { create(:user, :attendee) }
  let(:admin)     { create(:user, :admin) }
  let!(:event)    { create(:event, :published, venue: venue, organizer: organizer, capacity: 10, price: 20.00) }

  # ── Index ─────────────────────────────────────────────────────────────────
  describe "GET /bookings" do
    context "when not signed in" do
      it "redirects to sign in" do
        get bookings_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when signed in as attendee" do
      before { sign_in attendee }

      it "returns success" do
        get bookings_path
        expect(response).to have_http_status(:ok)
      end

      it "shows only own bookings" do
        own_booking   = create(:booking, :confirmed, user: attendee, event: event)
        other_booking = create(:booking, :confirmed, user: create(:user), event: event,
                               reference_code: "EF-OTHER001")
        get bookings_path
        expect(response.body).to include(own_booking.reference_code)
        expect(response.body).not_to include(other_booking.reference_code)
      end
    end

    context "when signed in as admin" do
      before { sign_in admin }

      it "shows all bookings" do
        booking_a = create(:booking, :confirmed, user: attendee, event: event)
        booking_b = create(:booking, :confirmed, user: create(:user), event: event,
                           reference_code: "EF-BCDE0001")
        get bookings_path
        expect(response.body).to include(booking_a.reference_code)
        expect(response.body).to include(booking_b.reference_code)
      end
    end
  end

  # ── Show ──────────────────────────────────────────────────────────────────
  describe "GET /bookings/:id" do
    let!(:booking) { create(:booking, :confirmed, user: attendee, event: event) }

    context "when signed in as owner" do
      before { sign_in attendee }

      it "returns success" do
        get booking_path(booking)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(booking.reference_code)
      end
    end

    context "when signed in as a different user" do
      before { sign_in create(:user) }

      it "redirects to root with a not authorized flash" do
        get booking_path(booking)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  # ── New ───────────────────────────────────────────────────────────────────
  describe "GET /events/:event_id/bookings/new" do
    before { sign_in attendee }

    it "returns success and shows seat map" do
      get new_event_booking_path(event)
      expect(response).to have_http_status(:ok)
    end
  end

  # ── Create ────────────────────────────────────────────────────────────────
  describe "POST /events/:event_id/bookings" do
    let(:seats) { venue.seats.first(2) }

    context "when signed in" do
      before { sign_in attendee }

      it "creates a booking with seats and redirects" do
        expect {
          post event_bookings_path(event), params: { seat_ids: seats.map(&:id) }
        }.to change(Booking, :count).by(1)
        expect(response).to redirect_to(booking_path(Booking.last))
      end

      it "does not create duplicate bookings" do
        post event_bookings_path(event), params: { seat_ids: seats.map(&:id) }
        expect {
          post event_bookings_path(event), params: { seat_ids: seats.map(&:id) }
        }.not_to change(Booking, :count)
      end
    end

    context "when no seats selected" do
      before { sign_in attendee }

      it "redirects back with alert" do
        post event_bookings_path(event), params: { seat_ids: [] }
        expect(response).to redirect_to(new_event_booking_path(event))
      end
    end
  end

  # ── Cancel ────────────────────────────────────────────────────────────────
  describe "PATCH /bookings/:id/cancel" do
    let!(:booking) { create(:booking, :confirmed, user: attendee, event: event) }

    context "as owner" do
      before { sign_in attendee }

      it "cancels the booking" do
        patch cancel_booking_path(booking)
        expect(booking.reload.status).to eq("cancelled")
      end
    end

    context "as a different user" do
      before { sign_in create(:user) }

      it "denies and redirects" do
        patch cancel_booking_path(booking)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
