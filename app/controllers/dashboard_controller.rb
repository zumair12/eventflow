# frozen_string_literal: true

class DashboardController < ApplicationController
  def index
    @upcoming_events = policy_scope(Event).upcoming.limit(6)
    @total_events    = policy_scope(Event).count
    @total_bookings  = policy_scope(Booking).count

    if current_user.admin?
      @total_users    = User.count
      @revenue        = Booking.confirmed.sum(:total_amount)
      @events_by_month = Event.published.group_by_month(:start_at, last: 6).count
      @bookings_by_status = Booking.group(:status).count
    elsif current_user.organizer?
      @my_events  = current_user.organized_events.count
      @my_revenue = Booking.confirmed.joins(:event)
                           .where(events: { organizer: current_user })
                           .sum(:total_amount)
    end

    @my_upcoming_bookings = current_user.bookings.confirmed
                                        .for_upcoming_events
                                        .includes(:event)
                                        .limit(5)
  end
end
