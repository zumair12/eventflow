# frozen_string_literal: true

FactoryBot.define do
  factory :venue do
    name        { Faker::Company.name + " Arena" }
    address     { Faker::Address.street_address }
    city        { Faker::Address.city }
    rows        { 5 }
    columns     { 6 }
    description { Faker::Lorem.sentence }
  end
end
