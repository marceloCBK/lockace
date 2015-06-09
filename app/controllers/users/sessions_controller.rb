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
    @mensagens = []

    # id = reconhecer
    # sign_in(:user, User.find(id)) unless id.blank?

    # Cadastro com imagem
    if params[:useFace]
      id = reconhecer
      @signIn = sign_in(:user, User.find(id)) unless id.blank?
      self.resource = resource_class.new(sign_in_params)

      # flash[:notice]    = @response
      # flash[:relatorio] = @relatorio
      # flash[:mensagens] = JsonPath.on(@relatorio.to_json, "$..mensagem")

      unless @signIn
        render template: "users/sessions/new"
      else
        redirect_to "/", alert: "Olá #{@signIn.email}!"
      end
    else
      super
    end




    # super
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
