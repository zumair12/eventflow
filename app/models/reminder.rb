# frozen_string_literal: true

class Reminder < ApplicationRecord
  belongs_to :booking

  enum :reminder_type, { day_before: 0, one_hour: 1 }, prefix: true

  validates :remind_at, presence: true
  validates :reminder_type, presence: true

  scope :unsent, -> { where(sent: false) }
  scope :due, -> { unsent.where("remind_at <= ?", Time.current) }
  scope :upcoming, -> { unsent.where("remind_at > ?", Time.current).order(:remind_at) }

  def send_reminder!
    return if sent?
    BookingReminderMailer.reminder_email(booking, self).deliver_later
    update!(sent: true)
  end
end
