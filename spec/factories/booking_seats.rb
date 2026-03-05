# frozen_string_literal: true

FactoryBot.define do
  factory :booking_seat do
    association :booking
    association :seat
  end
end
