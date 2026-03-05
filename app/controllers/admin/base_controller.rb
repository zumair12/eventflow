# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  before_action :require_admin!

  layout "admin"

  private

  def require_admin!
    redirect_to root_path, alert: "Admin access required." unless current_user.admin?
  end
end
