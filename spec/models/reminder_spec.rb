# frozen_string_literal: true

require "rails_helper"

RSpec.describe Reminder, type: :model do
  let(:booking) { create(:booking, :confirmed, user: create(:user), event: create(:event, :published, venue: create(:venue), organizer: create(:user, :organizer))) }

  subject(:reminder) { build(:reminder, booking: booking) }

  # ── Associations ─────────────────────────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:booking) }
  end

  # ── Validations ───────────────────────────────────────────────────────────
  describe "validations" do
    it { is_expected.to validate_presence_of(:remind_at) }
    it { is_expected.to validate_presence_of(:reminder_type) }
  end

  # ── Enums ─────────────────────────────────────────────────────────────────
  describe "reminder_type enum" do
    it { is_expected.to define_enum_for(:reminder_type).with_values("day_before" => 0, "one_hour" => 1).with_prefix(:reminder_type) }
  end

  # ── Scopes ────────────────────────────────────────────────────────────────
  describe ".due" do
    it "returns unsent reminders with remind_at in the past" do
      past_reminder   = create(:reminder, booking: booking, remind_at: 1.hour.ago, sent: false)
      future_reminder = create(:reminder, booking: booking, remind_at: 2.hours.from_now, sent: false, reminder_type: :one_hour)
      expect(Reminder.due).to include(past_reminder)
      expect(Reminder.due).not_to include(future_reminder)
    end
  end

  describe ".unsent" do
    it "excludes sent reminders" do
      sent_reminder = create(:reminder, :sent, booking: booking)
      expect(Reminder.unsent).not_to include(sent_reminder)
    end
  end
end
