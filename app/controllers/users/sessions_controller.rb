class Users::SessionsController < Devise::SessionsController
# before_filter :configure_sign_in_params, only: [:create]
  include FacesAuthenticationHelper

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    @relatorio = []
    response = reconhecer
    flash[:notice] = response

    # sign_in(:user, User.find(1))
    super
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   # devise_parameter_sanitizer.for(:sign_in) << :attribute
  #   devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:urlFace, :email, :password) }
  # end
end
