# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Backend

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorized

  allow_browser versions: :modern

  private

  def handle_unauthorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back_or_to root_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name phone])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name phone bio avatar_url])
  end
end
