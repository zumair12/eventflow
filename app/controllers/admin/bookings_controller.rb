# frozen_string_literal: true

class Admin::BookingsController < Admin::BaseController
  def index
    @pagy, @bookings = pagy(
      Booking.includes(:user, :event, :seats).recent,
      limit: 25
    )
  end

  def show
    @booking = Booking.find(params[:id])
  end
end
