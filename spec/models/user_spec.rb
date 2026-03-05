# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  # ── Associations ─────────────────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to have_many(:organized_events).class_name("Event").dependent(:destroy) }
    it { is_expected.to have_many(:bookings).dependent(:destroy) }
    it { is_expected.to have_many(:booked_events).through(:bookings).source(:event) }
  end

  # ── Validations ───────────────────────────────────────────────────────────
  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_length_of(:first_name).is_at_most(50) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(50) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  # ── Enums ─────────────────────────────────────────────────────────────────
  describe "role enum" do
    it { is_expected.to define_enum_for(:role).with_values("attendee" => 0, "organizer" => 1, "admin" => 2).with_prefix(:role) }
  end

  # ── Instance Methods ──────────────────────────────────────────────────────
  describe "#full_name" do
    it "returns first and last name concatenated" do
      user.first_name = "Alice"
      user.last_name  = "Smith"
      expect(user.full_name).to eq("Alice Smith")
    end
  end

  describe "#initials" do
    it "returns uppercase initials" do
      user.first_name = "Alice"
      user.last_name  = "Smith"
      expect(user.initials).to eq("AS")
    end
  end

  describe "#admin?" do
    it "returns true for admin role" do
      expect(build(:user, :admin).admin?).to be true
    end

    it "returns false for attendee" do
      expect(build(:user, :attendee).admin?).to be false
    end
  end

  describe "#organizer?" do
    it "returns true for organizer role" do
      expect(build(:user, :organizer).organizer?).to be true
    end

    it "returns true for admin role (admin can organize)" do
      expect(build(:user, :admin).organizer?).to be true
    end

    it "returns false for attendee" do
      expect(build(:user, :attendee).organizer?).to be false
    end
  end

  # ── Scopes ────────────────────────────────────────────────────────────────
  describe ".search_by_name_or_email" do
    let!(:alice) { create(:user, first_name: "Alice", last_name: "Smith", email: "alice@test.com") }
    let!(:bob)   { create(:user, first_name: "Bob", last_name: "Jones", email: "bob@test.com") }

    it "finds by first name" do
      expect(User.search_by_name_or_email("Ali")).to include(alice)
      expect(User.search_by_name_or_email("Ali")).not_to include(bob)
    end

    it "finds by email" do
      expect(User.search_by_name_or_email("bob@")).to include(bob)
    end

    it "returns all when query blank" do
      expect(User.search_by_name_or_email("").count).to eq(User.count)
    end
  end
end
