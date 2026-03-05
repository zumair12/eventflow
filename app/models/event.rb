# frozen_string_literal: true

class Event < ApplicationRecord
  belongs_to :venue
  belongs_to :organizer, class_name: "User", foreign_key: :organizer_id, inverse_of: :organized_events

  has_many :bookings, dependent: :destroy
  has_many :attendees, through: :bookings, source: :user
  has_one_attached :cover_image

  enum :status, {
    draft: 0,
    published: 1,
    cancelled: 2,
    completed: 3
  }, prefix: true

  CATEGORIES = %w[conference concert workshop sports exhibition meetup festival other].freeze

  validates :title, presence: true, length: { maximum: 150 }
  validates :description, presence: true
  validates :start_at, :end_at, presence: true
  validates :capacity, numericality: { greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :category, inclusion: { in: CATEGORIES }, allow_blank: true
  validate :end_at_after_start_at
  validate :capacity_within_venue_limit

  scope :upcoming, -> { where("start_at > ?", Time.current).published }
  scope :published, -> { where(status: :published) }
  scope :past, -> { where("end_at < ?", Time.current) }
  scope :for_category, ->(cat) { where(category: cat) if cat.present? }
  scope :search, ->(q) { where("title ILIKE ? OR description ILIKE ?", "%#{q}%", "%#{q}%") if q.present? }

  before_create :set_default_status

  def available_seats_count
    total_booked = bookings.confirmed.sum(:total_seats)
    capacity - total_booked
  end

  def sold_out?
    available_seats_count <= 0
  end

  def free?
    price.zero?
  end

  def has_bookings?
    bookings.confirmed.exists?
  end

  def duration_in_hours
    ((end_at - start_at) / 3600).round(1)
  end

  def booked_by?(user)
    bookings.confirmed.exists?(user: user)
  end

  private

  def end_at_after_start_at
    return unless start_at && end_at
    errors.add(:end_at, "must be after start time") if end_at <= start_at
  end

  def capacity_within_venue_limit
    return unless venue && capacity
    if capacity > venue.total_capacity
      errors.add(:capacity, "cannot exceed venue capacity of #{venue.total_capacity}")
    end
  end

  def set_default_status
    self.status ||= :draft
  end
end
