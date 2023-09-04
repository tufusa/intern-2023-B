class ApplicationController < ActionController::Base
  include SessionsHelper
  around_action :switch_locale

  private

    # ユーザーのログインを確認する
    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to login_url, status: :see_other
      end
    end

    # クエリパラメータのlocaleを遷移後も引き継ぐ
    def default_url_options
      { locale: I18n.locale }
    end

    # クエリパラメータでlocaleを変える
    def switch_locale(&action)
      locale = params[:locale] || I18n.default_locale
      I18n.with_locale(locale, &action)
    end
end
