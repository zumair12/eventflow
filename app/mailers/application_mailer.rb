# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: "EventFlow <noreply@eventflow.app>"
  layout "mailer"
end
