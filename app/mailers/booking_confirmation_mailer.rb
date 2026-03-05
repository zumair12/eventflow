# frozen_string_literal: true

class BookingConfirmationMailer < ApplicationMailer
  def confirmation_email(booking)
    @booking = booking
    @event   = booking.event
    @user    = booking.user
    @seats   = booking.seats

    mail(
      to: @user.email,
      subject: "Booking Confirmed: #{@event.title} — #{@booking.reference_code}"
    )
  end
end
