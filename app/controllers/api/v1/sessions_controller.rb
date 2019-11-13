class Api::V1::SessionsController < Api::V1::BaseController
  before_action :load_user, only: [:sign_in]

  def sign_in
    if @user && @user.valid_password?(params[:user][:password])
      @user.update({timezone: params[:user][:timezone]}) if params[:user][:timezone].present?
      token = TokenIssuer.create_and_return_token(@user, request, device_info)
      Device.update_or_create_by({user_id: @user.id},{player_pid: params[:user][:player_pid]}) if params[:user][:player_pid].present?
      # render_object(@user, 'auth_token': token)
      render_object @user, {class_name: "StaticUser", 'auth_token': token}
    else
      render_error 'Email or Password is incorrect'
    end
  end

  def destroy
    TokenIssuer.expire_token(current_user, request) if current_user
    render_success
  end


  private

  def load_user
    @user = User.find_by!(email: params[:user][:email])
  end

  def device_info
    params.permit(:device_type, :device_token)
  end

end