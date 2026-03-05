# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventPolicy, type: :policy do
  let(:venue)     { create(:venue) }
  let(:organizer) { create(:user, :organizer) }
  let(:admin)     { create(:user, :admin) }
  let(:attendee)  { create(:user, :attendee) }
  let(:other_org) { create(:user, :organizer) }

  let(:published_event) { create(:event, :published, venue: venue, organizer: organizer) }
  let(:draft_event)     { create(:event, :draft, venue: venue, organizer: organizer) }

  subject(:policy) { described_class }

  # ── Index ─────────────────────────────────────────────────────────────────
  describe "#index?" do
    it "allows anyone" do
      expect(policy.new(nil, published_event).index?).to be true
    end
  end

  # ── Show ──────────────────────────────────────────────────────────────────
  describe "#show?" do
    it "allows attendee to view published" do
      expect(policy.new(attendee, published_event).show?).to be true
    end

    it "denies attendee from seeing draft" do
      expect(policy.new(attendee, draft_event).show?).to be false
    end

    it "allows organizer to see own draft" do
      expect(policy.new(organizer, draft_event).show?).to be true
    end

    it "allows admin to see any event" do
      expect(policy.new(admin, draft_event).show?).to be true
    end
  end

  # ── Create ────────────────────────────────────────────────────────────────
  describe "#create?" do
    it "allows organizer to create" do
      expect(policy.new(organizer, Event.new).create?).to be true
    end

    it "allows admin to create" do
      expect(policy.new(admin, Event.new).create?).to be true
    end

    it "denies attendee from creating" do
      expect(policy.new(attendee, Event.new).create?).to be false
    end
  end

  # ── Update ────────────────────────────────────────────────────────────────
  describe "#update?" do
    it "allows organizer to update own event" do
      expect(policy.new(organizer, published_event).update?).to be true
    end

    it "denies organizer from updating another's event" do
      expect(policy.new(other_org, published_event).update?).to be false
    end

    it "allows admin to update any event" do
      expect(policy.new(admin, published_event).update?).to be true
    end
  end

  # ── Destroy ───────────────────────────────────────────────────────────────
  describe "#destroy?" do
    it "allows admin to destroy event without bookings" do
      expect(policy.new(admin, published_event).destroy?).to be true
    end

    it "allows organizer to destroy own event without bookings" do
      expect(policy.new(organizer, published_event).destroy?).to be true
    end

    it "denies attendee from destroying" do
      expect(policy.new(attendee, published_event).destroy?).to be false
    end
  end

  # ── Scope ─────────────────────────────────────────────────────────────────
  describe "Scope" do
    let!(:pub_event)   { create(:event, :published, venue: venue, organizer: organizer) }
    let!(:draft_event2) { create(:event, :draft, venue: venue, organizer: organizer) }
    let!(:other_draft) { create(:event, :draft, venue: venue, organizer: other_org) }

    it "shows only published events to attendees" do
      scope = EventPolicy::Scope.new(attendee, Event).resolve
      expect(scope).to include(pub_event)
      expect(scope).not_to include(draft_event2)
    end

    it "shows organizer own + published events" do
      scope = EventPolicy::Scope.new(organizer, Event).resolve
      expect(scope).to include(pub_event, draft_event2)
      expect(scope).not_to include(other_draft)
    end

    it "shows admin all events" do
      scope = EventPolicy::Scope.new(admin, Event).resolve
      expect(scope).to include(pub_event, draft_event2, other_draft)
    end
  end
end
