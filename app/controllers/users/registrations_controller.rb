class Users::RegistrationsController < Devise::RegistrationsController
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]
include FacesAuthenticationHelper

  @json = '{"status":"success","photos":[{"url":"http://api.skybiometry.com/fc/images/get?id=bmN2X3hybD0wcW44bnJwbzVwNTc0MnE1ODI4cXExczNxcG84MDNyMyZuY3ZfZnJwZXJnPXM1bm9zODJyM3AzMDQzN3FuNG4xNDkzNTcwbzJycnEwJmVxPTk2OTUmY3ZxPTY2cDY1NDQ3NjBzMTYmZ3Z6cmZnbnpjPTIwMTUwNjA1MDE0NzUz","pid":"F@0da7f39f3e72abe16a1af9685812c4ab_66c6544760f16","width":300,"height":150,"tags":[{"uids":[],"label":null,"confirmed":false,"manual":false,"width":18.0,"height":36.0,"yaw":24,"roll":6,"pitch":0,"attributes":{"face":{"value":"true","confidence":60}},"points":null,"similarities":null,"tid":"TEMP_F@0da7f39f3e72abe16a1af968009c005d_66c6544760f16_52.00_62.00_0_1","recognizable":true,"center":{"x":52.0,"y":62.0},"eye_left":{"x":54.0,"y":54.0,"confidence":52,"id":449},"eye_right":{"x":45.0,"y":51.33,"confidence":54,"id":450},"mouth_center":{"x":48.0,"y":72.67,"confidence":47,"id":615},"nose":{"x":48.67,"y":62.0,"confidence":54,"id":403}}]}],"usage":{"used":10,"remaining":90,"limit":100,"reset_time":1433474997,"reset_time_text":"Fri, 5 June 2015 03:29:57 +0000"},"operation_id":"75f8167817724037900c2614a9e4998d"}'
  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    @relatorio = []

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


    flash[:notice] = JsonPath.on(@relatorio.to_json, "$..mensagem")
    flash[:dados] = [id: id, tid: tid, faces: faces]
    flash[:mensagens] = @relatorio

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
  def configure_sign_up_params
    devise_parameter_sanitizer.for(:sign_up) << :attribute
  end

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
