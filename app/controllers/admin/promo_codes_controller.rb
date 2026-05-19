module Admin
  class PromoCodesController < BaseController
    def create
      @promo_code = PromoCode.new(promo_code_params)

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
      params.require(:promo_code).permit(:code, :discount_cents, :active)
    end
  end
end
