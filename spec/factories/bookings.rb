# frozen_string_literal: true

FactoryBot.define do
  factory :booking do
    association :user
    association :event
    status         { :confirmed }
    reference_code { "EF-#{SecureRandom.alphanumeric(8).upcase}" }
    total_seats    { 1 }
    total_amount   { 25.00 }

    trait :pending do
      status { :pending }
    end

    trait :confirmed do
      status { :confirmed }
    end

    trait :cancelled do
      status { :cancelled }
    end

    trait :waitlisted do
      status { :waitlisted }
    end

    trait :free do
      total_amount { 0.00 }
    end
  end
end
