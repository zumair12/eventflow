# frozen_string_literal: true

require "rails_helper"

RSpec.describe Venue, type: :model do
  subject(:venue) { build(:venue) }

  # ── Associations ─────────────────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to have_many(:seats).dependent(:destroy) }
    it { is_expected.to have_many(:events).dependent(:nullify) }
  end

  # ── Validations ───────────────────────────────────────────────────────────
  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:address) }
    it { is_expected.to validate_presence_of(:city) }
    it { is_expected.to validate_presence_of(:rows) }
    it { is_expected.to validate_presence_of(:columns) }
    it { is_expected.to validate_numericality_of(:rows).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:columns).is_greater_than(0) }
    it { is_expected.to validate_length_of(:name).is_at_most(100) }
  end

  # ── Seat Generation ───────────────────────────────────────────────────────
  describe "seat generation" do
    it "auto-generates seats on create" do
      venue = create(:venue, rows: 3, columns: 4)
      expect(venue.seats.count).to eq(12)
    end

    it "generates correct seat labels" do
      venue = create(:venue, rows: 2, columns: 3)
      labels = venue.seats.pluck(:label).sort
      expect(labels).to eq(%w[A1 A2 A3 B1 B2 B3])
    end

    it "sets all seats as available by default" do
      venue = create(:venue, rows: 2, columns: 2)
      expect(venue.seats.where(available: false).count).to eq(0)
    end
  end

  # ── Instance Methods ──────────────────────────────────────────────────────
  describe "#total_capacity" do
    it "calculates rows × columns" do
      venue.rows    = 5
      venue.columns = 8
      expect(venue.total_capacity).to eq(40)
    end
  end
end
