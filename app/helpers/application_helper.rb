# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def event_emoji(category)
    case category
    when "concert"    then "🎵"
    when "conference" then "🎤"
    when "workshop"   then "🛠️"
    when "sports"     then "⚽"
    when "exhibition" then "🎨"
    when "meetup"     then "🤝"
    when "festival"   then "🎊"
    else "🎉"
    end
  end

  def status_badge(status)
    mapping = {
      "draft"     => ["badge-warning",   "Draft"],
      "published" => ["badge-success",   "Published"],
      "cancelled" => ["badge-danger",    "Cancelled"],
      "completed" => ["badge-secondary", "Completed"]
    }
    css, label = mapping.fetch(status.to_s, ["badge-secondary", status.to_s.capitalize])
    content_tag(:span, label, class: "badge #{css}")
  end

  def booking_status_badge(status)
    mapping = {
      "confirmed"  => ["badge-success",  "✓ Confirmed"],
      "pending"    => ["badge-warning",  "⏳ Pending"],
      "cancelled"  => ["badge-danger",   "✕ Cancelled"],
      "waitlisted" => ["badge-info",     "🕐 Waitlisted"]
    }
    css, label = mapping.fetch(status.to_s, ["badge-secondary", status.to_s.capitalize])
    content_tag(:span, label, class: "badge #{css}")
  end

  def booking_status_color(status)
    case status.to_s
    when "confirmed"  then "success"
    when "pending"    then "warning"
    when "cancelled"  then "danger"
    when "waitlisted" then "info"
    else "secondary"
    end
  end

  def booking_status_emoji(status)
    case status.to_s
    when "confirmed"  then "✓"
    when "pending"    then "⏳"
    when "cancelled"  then "✕"
    when "waitlisted" then "⌛"
    else "?"
    end
  end
end
