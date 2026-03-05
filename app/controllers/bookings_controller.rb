# frozen_string_literal: true

class BookingsController < ApplicationController
  before_action :set_event, only: %i[new create]
  before_action :set_booking, only: %i[show cancel destroy]

  def index
    @pagy, @bookings = pagy(
      policy_scope(Booking).includes(:event, :seats)
                           .recent
                           .filter_by(params.slice(:status, :event_id, :q)),
      limit: 20
    )
    @status_counts = policy_scope(Booking).group(:status).count
  end

  def show
    authorize @booking
  end

  def new
    authorize Booking
    @seats = @event.venue.available_seats_for(@event).order(:row, :column)
    @seat_map = @seats.group_by(&:row)
    @booking = Booking.new
  end

  def create
    authorize Booking

    seat_ids = params[:seat_ids].to_a.map(&:to_i).uniq
    seats    = @event.venue.seats.where(id: seat_ids)

    if seats.empty?
      redirect_to new_event_booking_path(@event), alert: "Please select at least one seat." and return
    end

    @booking = BookingService.new(
      user: current_user,
      event: @event,
      seats: seats
    ).call

    if @booking.persisted?
      BookingConfirmationMailer.confirmation_email(@booking).deliver_later
      redirect_to booking_path(@booking), notice: "Booking confirmed! Reference: #{@booking.reference_code}"
    else
      @seats = @event.venue.available_seats_for(@event).order(:row, :column)
      @seat_map = @seats.group_by(&:row)
      render :new, status: :unprocessable_entity
    end
  end

  def cancel
    authorize @booking, :cancel?
    @booking.cancel!
    redirect_to booking_path(@booking), notice: "Booking has been cancelled."
  end

  def destroy
    authorize @booking
    @booking.destroy!
    redirect_to bookings_path, notice: "Booking deleted."
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  end

  def set_booking
    @booking = Booking.find(params[:id])
  end
end
