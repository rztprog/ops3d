module Admin
  class SettingsController < BaseController
    before_action :set_settings

    def edit
    end

    def update
      if @settings.update(settings_params)
        redirect_to edit_admin_settings_path, notice: "Paramètres mis à jour avec succès."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_settings
      @settings = Ops3dSetting.first_or_create!(
        shipping_mode: "free",
        shipping_price_cents: 0
      )
    end

    def settings_params
      permitted = params.require(:ops3d_setting).permit(
        :shipping_mode,
        :shipping_price_euros
      )

      if permitted[:shipping_mode] == "free"
        {
          shipping_mode: "free",
          shipping_price_cents: 0
        }
      else
        {
          shipping_mode: "flat_rate",
          shipping_price_cents: euros_to_cents(permitted[:shipping_price_euros])
        }
      end
    end

    def euros_to_cents(value)
      return 0 if value.blank?

      (BigDecimal(value.to_s.tr(",", ".")) * 100).to_i
    end
  end
end
