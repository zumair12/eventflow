# frozen_string_literal: true

class EventsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index show calendar]

  before_action :set_event, only: %i[show edit update destroy publish cancel]
  before_action :authorize_event!, only: %i[edit update destroy publish cancel]

  def index
    @events = policy_scope(Event).includes(:venue, :organizer)
                                 .search(params[:q])
                                 .for_category(params[:category])
    @events = @events.upcoming if params[:upcoming].present?
    @pagy, @events = pagy(@events.order(start_at: :asc), limit: 12)
    @categories = Event::CATEGORIES
  end

  def calendar
    @events = policy_scope(Event).published
                                 .includes(:venue, :bookings)
                                 .order(:start_at)
    @events_json = @events.map { |e| event_to_calendar_data(e) }.to_json
  end

  def show
    authorize @event
    @venue = @event.venue
    @seats = @venue.seats.order(:row, :column)
    @booked_seat_ids = Booking.confirmed
                              .where(event: @event)
                              .joins(:booking_seats)
                              .pluck("booking_seats.seat_id")
    @user_booking = current_user&.bookings&.find_by(event: @event)
  end

  def new
    @event = Event.new
    authorize @event
    @venues = Venue.all
  end

  def create
    @event = current_user.organized_events.build(event_params)
    authorize @event

    if @event.save
      redirect_to @event, notice: "Event was successfully created."
    else
      @venues = Venue.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @venues = Venue.all
  end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: "Event was successfully updated."
    else
      @venues = Venue.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy!
    redirect_to events_path, notice: "Event was successfully deleted."
  end

  def publish
    @event.update!(status: :published)
    redirect_to @event, notice: "Event published successfully."
  end

  def cancel
    @event.update!(status: :cancelled)
    redirect_to @event, notice: "Event has been cancelled."
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def authorize_event!
    authorize @event
  end

  def event_params
    params.expect(event: [:title, :description, :start_at, :end_at, :capacity,
                          :price, :category, :status, :venue_id, :location_note,
                          :cover_image])
  end

  def event_to_calendar_data(event)
    {
      id: event.id,
      title: event.title,
      start: event.start_at.iso8601,
      end: event.end_at.iso8601,
      url: event_path(event),
      color: event_color(event),
      extendedProps: {
        venue: event.venue.name,
        category: event.category,
        price: event.price,
        available_seats: event.available_seats_count
      }
    }
  end

  def event_color(event)
    case event.category
    when "concert"    then "#6366f1"
    when "conference" then "#0ea5e9"
    when "workshop"   then "#10b981"
    when "sports"     then "#f59e0b"
    when "festival"   then "#ec4899"
    when "exhibition" then "#a78bfa"
    when "meetup"     then "#34d399"
    else                   "#8b5cf6"
    end
  end
end
