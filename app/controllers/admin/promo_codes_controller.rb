module Admin
  class PromoCodesController < BaseController
    def create
      @promo_code = PromoCode.new(promo_code_params.except(:discount_euros))
      @promo_code.discount_cents = euros_to_cents(promo_code_params[:discount_euros])

      if @promo_code.save
        redirect_to edit_admin_settings_path, notice: "Code promo créé."
      else
        redirect_to edit_admin_settings_path, alert: @promo_code.errors.full_messages.to_sentence
      end
    end

    def destroy
      promo_code = PromoCode.find(params[:id])
      promo_code.destroy

      redirect_to edit_admin_settings_path, notice: "Code promo supprimé."
    end

    private

    def promo_code_params
      params.require(:promo_code).permit(:code, :discount_euros, :active)
    end

    def euros_to_cents(value)
      return 0 if value.blank?

      (BigDecimal(value.to_s.tr(",", ".")) * 100).to_i
    end
  end
end
