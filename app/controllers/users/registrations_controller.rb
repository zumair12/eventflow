# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  protected

  def after_sign_up_path_for(_resource)
    dashboard_path
  end

  def after_update_path_for(_resource)
    dashboard_path
  end
end
