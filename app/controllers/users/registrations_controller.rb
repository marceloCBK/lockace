class Users::RegistrationsController < Devise::RegistrationsController
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]
include FacesAuthenticationHelper

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    @relatorio = []
    @mensagens = []

    # Cadastro com imagem
    if params[:useFace]
      # Detecta imagem facial se "useFace" é true
      tid = detectar

      # Cadastra usuário no banco se um tid foi recebido
      unless tid.blank?
        super
        id = resource.id
      else
        build_resource(sign_up_params)
        render template: "users/registrations/new"
      end

      # Treina imagem recebida se o usuário já está cadastrado
      faces = cadastrar(tid, id) if !tid.blank? && !id.blank?
    else
      # Cadastro sem imagem
      super
    end


    # flash[:dados] = [id: id, tid: tid, faces: faces]
    # flash[:mensagens] = @relatorio

    # render :template => 'site/home'
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
