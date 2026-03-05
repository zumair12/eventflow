# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    title       { Faker::Music::RockBand.name + " Live #{rand(2025..2027)}" }
    description { Faker::Lorem.paragraphs(number: 2).join(" ") }
    start_at    { 3.days.from_now.change(hour: 18) }
    end_at      { 3.days.from_now.change(hour: 22) }
    capacity    { 20 }
    price       { 25.00 }
    category    { "concert" }
    status      { :published }
    association :venue
    association :organizer, factory: [:user, :organizer]

    trait :draft do
      status { :draft }
    end

    trait :published do
      status { :published }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :free do
      price { 0.00 }
    end

    trait :sold_out do
      capacity { 0 }
    end
  end
end
