# frozen_string_literal: true

class VenuesController < ApplicationController
  before_action :set_venue, only: %i[show edit update destroy]

  def index
    authorize Venue
    @pagy, @venues = pagy(Venue.order(:name), limit: 20)
  end

  def show
    authorize @venue
    @seats      = @venue.seats.order(:row, :column).group_by(&:row)
    @upcoming   = @venue.events.published.upcoming.limit(5)
  end

  def new
    @venue = Venue.new
    authorize @venue
  end

  def create
    @venue = Venue.new(venue_params)
    authorize @venue

    if @venue.save
      redirect_to @venue, notice: "Venue created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @venue
  end

  def update
    authorize @venue
    if @venue.update(venue_params)
      redirect_to @venue, notice: "Venue updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @venue
    @venue.destroy!
    redirect_to venues_path, notice: "Venue deleted."
  end

  private

  def set_venue
    @venue = Venue.find(params[:id])
  end

  def venue_params
    params.expect(venue: %i[name address city rows columns description image_url])
  end
end
