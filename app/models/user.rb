# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { attendee: 0, organizer: 1, admin: 2 }, prefix: true

  has_many :organized_events, class_name: "Event", foreign_key: :organizer_id,
                              dependent: :destroy, inverse_of: :organizer
  has_many :bookings, dependent: :destroy
  has_many :booked_events, through: :bookings, source: :event

  scope :search_by_name_or_email, ->(q) {
    return all if q.blank?
    where("first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q", q: "%#{q}%")
  }

  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :role, presence: true

  before_create :set_default_role

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def initials
    [first_name.first, last_name.first].join.upcase
  end

  def admin?
    role_admin?
  end

  def organizer?
    role_organizer? || role_admin?
  end

  private

  def set_default_role
    self.role ||= :attendee
  end
end
