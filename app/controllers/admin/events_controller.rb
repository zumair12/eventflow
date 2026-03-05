# frozen_string_literal: true

class Admin::EventsController < Admin::BaseController
  def index
    @pagy, @events = pagy(
      Event.includes(:venue, :organizer).order(start_at: :desc),
      limit: 25
    )
  end

  def show
    @event = Event.find(params[:id])
  end
end
