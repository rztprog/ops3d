class Users::RegistrationsController < Devise::RegistrationsController
  before_action :check_registrations_enabled, only: %i[new create]

  private

  def check_registrations_enabled
    return if Ops3dSetting.first&.registrations_enabled?

    redirect_to root_path,
      alert: "Les inscriptions sont actuellement fermées."
  end
end
