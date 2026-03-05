# frozen_string_literal: true

FactoryBot.define do
  factory :reminder do
    association :booking
    remind_at     { 1.day.from_now }
    sent          { false }
    reminder_type { :day_before }

    trait :one_hour do
      reminder_type { :one_hour }
      remind_at     { 1.hour.from_now }
    end

    trait :sent do
      sent { true }
    end
  end
end
