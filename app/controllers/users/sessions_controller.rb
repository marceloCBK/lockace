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
      # Identifica usuário
      ids = reconhecer.first

      unless ids.blank?
        # seleciona id de usuário
        uid = ids[:uid]
        id  = uid.split("@").first unless uid.blank?

        # seleciona tid da face
        tid = ids[:tid]
      end

      # Inicia sessão do usuário
      @signIn = sign_in(:user, User.find(id)) unless id.blank?

      # Treina uma nova face para melhorar o reconhecimento
      train = cadastrar(tid, id) if !id.blank?
      @relatorio << [train: train]

      # Gera um resource
      self.resource = resource_class.new(sign_in_params)

      # Verifica se o usuário foi logado
      if @signIn
        # Redireciona para pagina de boas vindas
        redirect_to "/", alert: "Olá #{@signIn.email}!"
      else
        # Recarrega pagina
        render template: "users/sessions/new"
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
