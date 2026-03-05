# frozen_string_literal: true

class Admin::DashboardController < Admin::BaseController
  def index
    @total_users    = User.count
    @total_events   = Event.count
    @total_bookings = Booking.count
    @total_revenue  = Booking.confirmed.sum(:total_amount)

    @recent_bookings = Booking.includes(:user, :event).recent.limit(10)
    @upcoming_events = Event.published.upcoming.includes(:venue).limit(5)

    @bookings_by_status = Booking.group(:status).count
    @events_by_category = Event.group(:category).count
    @revenue_by_month   = Booking.confirmed.group_by_month(:created_at, last: 6).sum(:total_amount)
    @users_by_role      = User.group(:role).count
  end
end
