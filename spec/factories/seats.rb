# frozen_string_literal: true

FactoryBot.define do
  factory :seat do
    association :venue
    row         { 1 }
    column      { 1 }
    label       { "A1" }
    seat_type   { :standard }
    available   { true }

    trait :vip do
      seat_type { :vip }
    end

    trait :accessible do
      seat_type { :accessible }
    end
  end
end
