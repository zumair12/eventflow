# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event, type: :model do
  let(:venue)     { create(:venue, rows: 5, columns: 6) }
  let(:organizer) { create(:user, :organizer) }

  subject(:event) do
    build(:event, venue: venue, organizer: organizer, capacity: 20)
  end

  # ── Associations ─────────────────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:venue) }
    it { is_expected.to belong_to(:organizer).class_name("User") }
    it { is_expected.to have_many(:bookings).dependent(:destroy) }
    it { is_expected.to have_many(:attendees).through(:bookings).source(:user) }
  end

  # ── Validations ───────────────────────────────────────────────────────────
  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:start_at) }
    it { is_expected.to validate_presence_of(:end_at) }
    it { is_expected.to validate_numericality_of(:capacity).is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
  end

  describe "end_at_after_start_at validation" do
    it "is invalid when end_at is before start_at" do
      event.start_at = 2.days.from_now
      event.end_at   = 1.day.from_now
      expect(event).not_to be_valid
      expect(event.errors[:end_at]).to include("must be after start time")
    end

    it "is valid when end_at is after start_at" do
      event.start_at = 1.day.from_now
      event.end_at   = 2.days.from_now
      expect(event).to be_valid
    end
  end

  describe "capacity_within_venue_limit validation" do
    it "is invalid when capacity exceeds venue total capacity" do
      event.capacity = venue.total_capacity + 1
      expect(event).not_to be_valid
      expect(event.errors[:capacity]).to be_present
    end

    it "is valid when capacity equals venue total capacity" do
      event.capacity = venue.total_capacity
      expect(event).to be_valid
    end
  end

  # ── Enums ─────────────────────────────────────────────────────────────────
  describe "status enum" do
    it { is_expected.to define_enum_for(:status).with_values("draft" => 0, "published" => 1, "cancelled" => 2, "completed" => 3).with_prefix(:status) }
  end

  # ── Scopes ────────────────────────────────────────────────────────────────
  describe ".upcoming" do
    let!(:past_event)    { create(:event, venue: venue, organizer: organizer, start_at: 2.days.ago, end_at: 1.day.ago) }
    let!(:future_event)  { create(:event, :published, venue: venue, organizer: organizer) }

    it "returns only future published events" do
      expect(Event.upcoming).to include(future_event)
      expect(Event.upcoming).not_to include(past_event)
    end
  end

  describe ".search" do
    let!(:concert) { create(:event, title: "Jazz Night", venue: venue, organizer: organizer) }
    let!(:conf)    { create(:event, title: "Tech Summit", venue: venue, organizer: organizer) }

    it "finds by title" do
      expect(Event.search("Jazz")).to include(concert)
      expect(Event.search("Jazz")).not_to include(conf)
    end

    it "returns all when query blank" do
      expect(Event.search(nil)).to include(concert, conf)
    end
  end

  # ── Instance Methods ──────────────────────────────────────────────────────
  describe "#free?" do
    it "returns true when price is zero" do
      event.price = 0
      expect(event.free?).to be true
    end

    it "returns false when price is positive" do
      event.price = 25.00
      expect(event.free?).to be false
    end
  end

  describe "#duration_in_hours" do
    it "calculates duration correctly" do
      event.start_at = Time.current
      event.end_at   = Time.current + 3.hours
      expect(event.duration_in_hours).to eq(3.0)
    end
  end

  describe "#available_seats_count" do
    let!(:saved_event) { create(:event, :published, venue: venue, organizer: organizer, capacity: 10) }
    let(:attendee)     { create(:user) }

    it "returns full capacity when no bookings" do
      expect(saved_event.available_seats_count).to eq(10)
    end

    it "decreases by confirmed bookings" do
      create(:booking, event: saved_event, user: attendee, status: :confirmed, total_seats: 3)
      expect(saved_event.available_seats_count).to eq(7)
    end

    it "does not decrease for cancelled bookings" do
      create(:booking, event: saved_event, user: attendee, status: :cancelled, total_seats: 3)
      expect(saved_event.available_seats_count).to eq(10)
    end
  end

  describe "#sold_out?" do
    it "returns true when no seats available" do
      allow(event).to receive(:available_seats_count).and_return(0)
      expect(event.sold_out?).to be true
    end

    it "returns false when seats available" do
      allow(event).to receive(:available_seats_count).and_return(5)
      expect(event.sold_out?).to be false
    end
  end

  describe "#has_bookings?" do
    let!(:saved_event) { create(:event, :published, venue: venue, organizer: organizer) }

    it "returns false when no confirmed bookings" do
      expect(saved_event.has_bookings?).to be false
    end

    it "returns true when confirmed bookings exist" do
      create(:booking, event: saved_event, user: create(:user), status: :confirmed)
      expect(saved_event.has_bookings?).to be true
    end
  end
end
