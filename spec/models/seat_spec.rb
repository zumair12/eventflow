# frozen_string_literal: true

require "rails_helper"

RSpec.describe Seat, type: :model do
  let(:venue) { create(:venue, rows: 3, columns: 4) }

  subject(:seat) { venue.seats.first }

  # ── Associations ─────────────────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:venue) }
    it { is_expected.to have_many(:booking_seats).dependent(:destroy) }
    it { is_expected.to have_many(:bookings).through(:booking_seats) }
  end

  # ── Validations ───────────────────────────────────────────────────────────
  describe "validations" do
    it { is_expected.to validate_presence_of(:row) }
    it { is_expected.to validate_presence_of(:column) }
    it { is_expected.to validate_presence_of(:label) }
    it { is_expected.to validate_numericality_of(:row).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:column).is_greater_than(0) }
    it { is_expected.to validate_uniqueness_of(:label).scoped_to(:venue_id) }
  end

  # ── Enums ─────────────────────────────────────────────────────────────────
  describe "seat_type enum" do
    it { is_expected.to define_enum_for(:seat_type).with_values("standard" => 0, "vip" => 1, "accessible" => 2).with_prefix(:seat_type) }
  end

  # ── Scopes ────────────────────────────────────────────────────────────────
  describe ".available" do
    it "returns seats where available is true" do
      scoped_count = venue.seats.available.count
      expect(scoped_count).to eq(venue.total_capacity)
    end
  end
end
