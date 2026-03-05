# frozen_string_literal: true

class VenuePolicy < ApplicationPolicy
  def index? = true
  def show? = true
  def create? = user&.admin?
  def new? = create?
  def update? = user&.admin?
  def edit? = update?
  def destroy? = user&.admin?

  class Scope < ApplicationPolicy::Scope
    def resolve = scope.all
  end
end
