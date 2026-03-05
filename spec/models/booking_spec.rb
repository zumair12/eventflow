# frozen_string_literal: true

require "rails_helper"

RSpec.describe Booking, type: :model do
  let(:venue)    { create(:venue, rows: 4, columns: 5) }
  let(:event)    { create(:event, :published, venue: venue, organizer: create(:user, :organizer), capacity: 10) }
  let(:user)     { create(:user) }

  subject(:booking) { build(:booking, user: user, event: event) }

  # ── Associations ─────────────────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:event) }
    it { is_expected.to have_many(:booking_seats).dependent(:destroy) }
    it { is_expected.to have_many(:seats).through(:booking_seats) }
    it { is_expected.to have_many(:reminders).dependent(:destroy) }
  end

  # ── Validations ───────────────────────────────────────────────────────────
  describe "validations" do
    it "requires a reference code on save" do
      b = Booking.new(user: user, event: event, status: :confirmed, total_seats: 1, total_amount: 0)
      b.valid? # triggers before_validation callback
      expect(b.reference_code).to be_present
    end
    it { is_expected.to validate_numericality_of(:total_seats).is_greater_than(0) }
  end

  # ── Enums ─────────────────────────────────────────────────────────────────
  describe "status enum" do
    it { is_expected.to define_enum_for(:status).with_values("pending" => 0, "confirmed" => 1, "cancelled" => 2, "waitlisted" => 3).with_prefix(:status) }
  end

  # ── Reference Code Generation ─────────────────────────────────────────────
  describe "reference_code generation" do
    it "auto-generates a reference code before creation" do
      booking = Booking.new(user: user, event: event, status: :confirmed, total_seats: 1, total_amount: 0)
      booking.valid?
      expect(booking.reference_code).to match(/\AEF-[A-Z0-9]{8}\z/)
    end

    it "does not overwrite an existing reference code" do
      booking.reference_code = "EF-CUSTOM01"
      booking.valid?
      expect(booking.reference_code).to eq("EF-CUSTOM01")
    end
  end

  # ── Double-booking Validation ─────────────────────────────────────────────
  describe "user_not_double_booked validation" do
    it "prevents a second confirmed booking on the same event" do
      create(:booking, user: user, event: event, status: :confirmed, reference_code: "EF-FIRST001")
      dupe = build(:booking, user: user, event: event, status: :confirmed)
      expect(dupe).not_to be_valid
      expect(dupe.errors[:base]).to include("You already have a confirmed booking for this event")
    end

    it "allows booking if previous booking was cancelled" do
      create(:booking, user: user, event: event, status: :cancelled, reference_code: "EF-OLD00001")
      new_booking = build(:booking, user: user, event: event, status: :confirmed)
      expect(new_booking).to be_valid
    end
  end

  # ── Scopes ────────────────────────────────────────────────────────────────
  describe ".confirmed" do
    it "returns only confirmed bookings" do
      confirmed  = create(:booking, :confirmed, user: user, event: event)
      cancelled  = create(:booking, :cancelled, user: create(:user), event: event, reference_code: "EF-CANCEL01")
      expect(Booking.confirmed).to include(confirmed)
      expect(Booking.confirmed).not_to include(cancelled)
    end
  end

  describe ".recent" do
    it "orders by created_at desc" do
      older = create(:booking, :confirmed, user: user, event: event, created_at: 2.days.ago)
      newer = create(:booking, :confirmed, user: create(:user), event: event, created_at: 1.day.ago, reference_code: "EF-NEWER001")
      expect(Booking.recent.first).to eq(newer)
    end
  end

  # ── Instance Methods ──────────────────────────────────────────────────────
  describe "#cancel!" do
    let!(:saved_booking) { create(:booking, :confirmed, user: user, event: event) }

    it "changes status to cancelled" do
      saved_booking.cancel!
      expect(saved_booking.reload.status).to eq("cancelled")
    end

    it "destroys unsent reminders" do
      create(:reminder, booking: saved_booking, sent: false)
      saved_booking.cancel!
      expect(saved_booking.reminders.count).to eq(0)
    end
  end
end
