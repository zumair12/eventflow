# frozen_string_literal: true

class EventPolicy < ApplicationPolicy
  # Anyone can view published events
  def index? = true
  def show? = record.status_published? || user&.admin? || owned_by_user?

  def create? = user&.organizer? || user&.admin?
  def new? = create?

  def update? = user&.admin? || owned_by_user?
  def edit? = update?

  def destroy? = user&.admin? || (owned_by_user? && !record.has_bookings?)

  def publish? = user&.admin? || owned_by_user?
  def cancel? = user&.admin? || owned_by_user?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user&.organizer?
        scope.where(organizer: user).or(scope.published)
      else
        scope.published
      end
    end
  end

  private

  def owned_by_user?
    user && record.organizer_id == user.id
  end
end
