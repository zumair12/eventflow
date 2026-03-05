# frozen_string_literal: true

class Booking < ApplicationRecord
  belongs_to :user
  belongs_to :event

  has_many :booking_seats, dependent: :destroy
  has_many :seats, through: :booking_seats
  has_many :reminders, dependent: :destroy

  enum :status, {
    pending: 0,
    confirmed: 1,
    cancelled: 2,
    waitlisted: 3
  }, prefix: true

  validates :reference_code, presence: true, uniqueness: true
  validates :total_seats, numericality: { greater_than: 0 }
  validates :total_amount, numericality: { greater_than_or_equal_to: 0 }
  validate :event_not_sold_out, on: :create
  validate :user_not_double_booked, on: :create

  before_validation :generate_reference_code, on: :create
  after_create :schedule_reminders
  after_update :cancel_reminders, if: :status_previously_changed_to_cancelled?

  scope :recent, -> { order(created_at: :desc) }
  scope :confirmed, -> { where(status: :confirmed) }
  scope :for_upcoming_events, -> { joins(:event).where("events.start_at > ?", Time.current) }
  scope :filter_by, ->(filters) {
    result = all
    result = result.where(status: filters[:status]) if filters[:status].present?
    result = result.where(event_id: filters[:event_id]) if filters[:event_id].present?
    result = result.joins(:event).where("events.title ILIKE ?", "%#{filters[:q]}%") if filters[:q].present?
    result
  }

  def cancel!
    update!(status: :cancelled)
  end

  private

  def generate_reference_code
    self.reference_code ||= "EF-#{SecureRandom.alphanumeric(8).upcase}"
  end

  def event_not_sold_out
    errors.add(:base, "Event is sold out") if event&.sold_out?
  end

  def user_not_double_booked
    if event && user && event.bookings.confirmed.exists?(user: user)
      errors.add(:base, "You already have a confirmed booking for this event")
    end
  end

  def schedule_reminders
    # 24 hours before
    remind_at_24h = event.start_at - 24.hours
    reminders.create!(remind_at: remind_at_24h, reminder_type: :day_before) if remind_at_24h > Time.current

    # 1 hour before
    remind_at_1h = event.start_at - 1.hour
    reminders.create!(remind_at: remind_at_1h, reminder_type: :one_hour) if remind_at_1h > Time.current
  end

  def cancel_reminders
    reminders.where(sent: false).destroy_all
  end

  def status_previously_changed_to_cancelled?
    saved_change_to_status? && status_cancelled?
  end
end
