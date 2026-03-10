# frozen_string_literal: true
# db/seeds.rb — EventFlow Seed Data

puts "🌱 Seeding EventFlow..."

# ── Users ────────────────────────────────────────────────────────────────────
puts "  → Creating users…"

admin = User.find_or_create_by!(email: "admin@eventflow.app") do |u|
  u.first_name = "Alex"
  u.last_name  = "Nova"
  u.password   = "password123"
  u.role       = :admin
  u.phone      = "+1 555-0001"
  u.bio        = "Platform administrator"
end

organizer1 = User.find_or_create_by!(email: "sam@eventflow.app") do |u|
  u.first_name = "Sam"
  u.last_name  = "Rivera"
  u.password   = "password123"
  u.role       = :organizer
  u.phone      = "+1 555-0002"
  u.bio        = "Concert & festival organizer"
end

organizer2 = User.find_or_create_by!(email: "jane@eventflow.app") do |u|
  u.first_name = "Jane"
  u.last_name  = "Park"
  u.password   = "password123"
  u.role       = :organizer
  u.phone      = "+1 555-0003"
  u.bio        = "Tech conference organizer"
end

attendees = 5.times.map do |i|
  User.find_or_create_by!(email: "user#{i + 1}@example.com") do |u|
    u.first_name = ["Alice", "Bob", "Carol", "Dan", "Eva"][i]
    u.last_name  = ["Smith", "Jones", "Brown", "Lee", "Kim"][i]
    u.password   = "password123"
    u.role       = :attendee
  end
end

puts "     ✓ #{User.count} users created"

# ── Venues ───────────────────────────────────────────────────────────────────
puts "  → Creating venues…"

grand_arena = Venue.find_or_create_by!(name: "Grand City Arena") do |v|
  v.address     = "100 Arena Blvd"
  v.city        = "New York"
  v.rows        = 8
  v.columns     = 12
  v.description = "Premier multi-purpose arena in the heart of downtown New York."
end

tech_hub = Venue.find_or_create_by!(name: "Tech Hub Conference Center") do |v|
  v.address     = "500 Innovation Drive"
  v.city        = "San Francisco"
  v.rows        = 6
  v.columns     = 10
  v.description = "State-of-the-art conference center for technology events."
end

arts_hall = Venue.find_or_create_by!(name: "The Arts Hall") do |v|
  v.address     = "22 Culture Street"
  v.city        = "Chicago"
  v.rows        = 5
  v.columns     = 8
  v.description = "An intimate performance hall for arts and cultural events."
end

puts "     ✓ #{Venue.count} venues created (#{Seat.count} seats auto-generated)"

# ── Events ───────────────────────────────────────────────────────────────────
puts "  → Creating events…"

events_data = [
  {
    title:       "SoundWave Music Festival 2026",
    description: "An electrifying night of live music featuring world-class artists across three stages. Expect stunning light shows, food stalls, and an unforgettable atmosphere.",
    start_at:    3.days.from_now.change(hour: 18, min: 0),
    end_at:      3.days.from_now.change(hour: 23, min: 0),
    capacity:    80,
    price:       45.00,
    category:    "festival",
    status:      :published,
    venue:       grand_arena,
    organizer:   organizer1
  },
  {
    title:       "RailsConf 2026",
    description: "The premier Ruby on Rails conference bringing together developers from around the world. Two days of talks, workshops, and networking.",
    start_at:    7.days.from_now.change(hour: 9, min: 0),
    end_at:      8.days.from_now.change(hour: 18, min: 0),
    capacity:    50,
    price:       120.00,
    category:    "conference",
    status:      :published,
    venue:       tech_hub,
    organizer:   organizer2
  },
  {
    title:       "Jazz Under the Stars",
    description: "An intimate evening of live jazz music in a beautifully lit intimate hall. Featuring top local jazz musicians and a special guest performance.",
    start_at:    10.days.from_now.change(hour: 20, min: 0),
    end_at:      10.days.from_now.change(hour: 23, min: 30),
    capacity:    35,
    price:       25.00,
    category:    "concert",
    status:      :published,
    venue:       arts_hall,
    organizer:   organizer1
  },
  {
    title:       "React & Next.js Workshop",
    description: "Hands-on workshop for intermediate developers. Learn the latest React patterns, server components, and Next.js App Router best practices.",
    start_at:    5.days.from_now.change(hour: 10, min: 0),
    end_at:      5.days.from_now.change(hour: 17, min: 0),
    capacity:    45,
    price:       0.00,
    category:    "workshop",
    status:      :published,
    venue:       tech_hub,
    organizer:   organizer2
  },
  {
    title:       "Summer Sports Showcase",
    description: "A spectacular display of competitive sports featuring local and national athletics. Tickets include access to all arenas and food courts.",
    start_at:    14.days.from_now.change(hour: 11, min: 0),
    end_at:      14.days.from_now.change(hour: 20, min: 0),
    capacity:    90,
    price:       18.00,
    category:    "sports",
    status:      :published,
    venue:       grand_arena,
    organizer:   organizer1
  },
  {
    title:       "Modern Art Exhibition: Chromatic",
    description: "An immersive art exhibition featuring works from 40 contemporary artists exploring the theme of color and emotion.",
    start_at:    2.days.from_now.change(hour: 10, min: 0),
    end_at:      2.days.from_now.change(hour: 20, min: 0),
    capacity:    30,
    price:       12.00,
    category:    "exhibition",
    status:      :published,
    venue:       arts_hall,
    organizer:   organizer2
  },
  {
    title:       "Startup Meetup — Q1 2026",
    description: "Monthly networking event for founders, investors and startup enthusiasts. Pitches, panels, and plenty of networking.",
    start_at:    21.days.from_now.change(hour: 18, min: 30),
    end_at:      21.days.from_now.change(hour: 21, min: 30),
    capacity:    55,
    price:       0.00,
    category:    "meetup",
    status:      :published,
    venue:       tech_hub,
    organizer:   organizer1
  },
  {
    title:       "Secret After-Party (Draft)",
    description: "An exclusive after-party event — coming soon.",
    start_at:    30.days.from_now.change(hour: 22, min: 0),
    end_at:      31.days.from_now.change(hour: 2, min: 0),
    capacity:    40,
    price:       60.00,
    category:    "concert",
    status:      :draft,
    venue:       grand_arena,
    organizer:   organizer1
  }
]

created_events = events_data.map do |data|
  event = Event.find_or_initialize_by(title: data[:title], organizer: data[:organizer])
  event.assign_attributes(
    description: data[:description],
    start_at:    data[:start_at],
    end_at:      data[:end_at],
    capacity:    data[:capacity],
    price:       data[:price],
    category:    data[:category],
    status:      data[:status],
    venue:       data[:venue]
  )
  event.save!
  event
end

puts "     ✓ #{Event.count} events created"

# ── Sample Bookings ──────────────────────────────────────────────────────────
puts "  → Creating sample bookings…"

# Book seats for Alice (attendee 0) on the first published event
published_events = created_events.select(&:status_published?)

published_events.first(3).each_with_index do |event, idx|
  user = attendees[idx]
  next if event.bookings.exists?(user: user)

  available_seats = event.venue.seats.first(2)
  next if available_seats.empty?

  booking = BookingService.new(
    user:  user,
    event: event,
    seats: available_seats
  ).call

  puts "     ✓ Booking #{booking.reference_code} created for #{user.full_name}" if booking.persisted?
end

puts "     ✓ #{Booking.count} bookings created"

puts ""
puts "✅ Seeding complete!"
puts ""
puts "  Default accounts:"
puts "  ┌─────────────────────────────────────────┬──────────────┬───────────┐"
puts "  │ Email                                   │ Password     │ Role      │"
puts "  ├─────────────────────────────────────────┼──────────────┼───────────┤"
puts "  │ admin@eventflow.app                     │ password123  │ Admin     │"
puts "  │ sam@eventflow.app                       │ password123  │ Organizer │"
puts "  │ jane@eventflow.app                      │ password123  │ Organizer │"
puts "  │ user1@example.com                       │ password123  │ Attendee  │"
puts "  └─────────────────────────────────────────┴──────────────┴───────────┘"
puts ""
