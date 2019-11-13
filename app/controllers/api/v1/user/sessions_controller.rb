class Api::V1::User::SessionsController < Devise::SessionsController
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  def create
    @user = warden.authenticate!(auth_options)
    @token = Tiddle.create_and_return_token(@user, request, expires_in: 1.month)
    render json: { message: "User logged in successfully", auth_token: @token, status: 200}  
  end

  def destroy
    Tiddle.expire_token(current_user, request) if current_user
    render json: {}
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
