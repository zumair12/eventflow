# frozen_string_literal: true

require "rails_helper"

RSpec.describe BookingPolicy, type: :policy do
  let(:user)    { create(:user) }
  let(:other)   { create(:user) }
  let(:admin)   { create(:user, :admin) }
  let(:venue)   { create(:venue) }
  let(:event)   { create(:event, :published, venue: venue, organizer: create(:user, :organizer)) }
  let(:booking) { create(:booking, :confirmed, user: user, event: event) }

  subject(:policy) { described_class }

  describe "#show?" do
    it "allows owner to see own booking" do
      expect(policy.new(user, booking).show?).to be true
    end

    it "allows admin to see any booking" do
      expect(policy.new(admin, booking).show?).to be true
    end

    it "denies another user" do
      expect(policy.new(other, booking).show?).to be false
    end
  end

  describe "#create?" do
    it "allows any signed-in user" do
      expect(policy.new(user, booking).create?).to be true
    end
  end

  describe "#cancel?" do
    it "allows owner to cancel" do
      expect(policy.new(user, booking).cancel?).to be true
    end

    it "denies a non-owner" do
      expect(policy.new(other, booking).cancel?).to be false
    end

    it "allows admin to cancel" do
      expect(policy.new(admin, booking).cancel?).to be true
    end
  end

  describe "Scope" do
    let!(:own_booking)   { create(:booking, :confirmed, user: user, event: event) }
    let!(:other_booking) { create(:booking, :confirmed, user: other, event: event,
                                  reference_code: "EF-OTHER001") }

    it "returns only user's own bookings" do
      scope = BookingPolicy::Scope.new(user, Booking).resolve
      expect(scope).to include(own_booking)
      expect(scope).not_to include(other_booking)
    end

    it "returns all bookings for admin" do
      scope = BookingPolicy::Scope.new(admin, Booking).resolve
      expect(scope).to include(own_booking, other_booking)
    end
  end
end
