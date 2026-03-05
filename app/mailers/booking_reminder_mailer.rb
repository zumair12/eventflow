# frozen_string_literal: true

class BookingReminderMailer < ApplicationMailer
  def reminder_email(booking, reminder)
    @booking  = booking
    @reminder = reminder
    @event    = booking.event
    @user     = booking.user

    mail(
      to: @user.email,
      subject: "Reminder: #{@event.title} is #{reminder_label(reminder)}"
    )
  end

  private

  def reminder_label(reminder)
    case reminder.reminder_type
    when "day_before" then "tomorrow!"
    when "one_hour"   then "starting in 1 hour!"
    else "coming up soon!"
    end
  end
end
