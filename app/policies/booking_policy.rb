# frozen_string_literal: true

class BookingPolicy < ApplicationPolicy
  def index? = user.present?
  def show? = user&.admin? || own_booking?
  def create? = user.present?
  def new? = create?
  def destroy? = user&.admin? || own_booking?
  def cancel? = user&.admin? || own_booking?

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end

  private

  def own_booking?
    user && record.user_id == user.id
  end
end
