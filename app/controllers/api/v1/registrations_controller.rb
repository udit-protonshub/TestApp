class Api::V1::RegistrationsController < Api::V1::BaseController
  before_action :set_user_by_email, only: [:forgot_password]

  def sign_up
    @user = User.new(register_params)
    if @user.save
      token = TokenIssuer.create_and_return_token(@user, request, device_info)
      Device.update_or_create_by({user_id: @user.id},{player_pid: params[:user][:player_pid]}) if params[:user][:player_pid].present?
      # UserMailer.send_new_user_message(@user).deliver
      render_object @user, {class_name: "StaticUser", 'auth_token': token}
    else
      render_error @user.errors.full_messages
    end
  end

  def forgot_password
    @user.send_reset_password_instructions
    # @user.send(:set_reset_password_token)
    render_success
  end

  def reset_password
    @user = User.reset_password_by_token(reset_password_params)
    reset_errors = @user.errors
    if reset_errors.present?
      render_error reset_errors.full_messages
    else
      token = TokenIssuer.create_and_return_token(@user, request, device_info)
      render_object(@user, 'auth_token': token)
    end
  end

  private
  def register_params
    params.require(:user).permit(:full_name, :email, :phone_number, :password, :timezone, current_location: {})
  end

  def device_info
    params.permit(:device_type, :device_token)
  end

  def set_user_by_email
    @user = User.find_by!(email: params[:email])
  end

  def reset_password_params
    params.require(:user).permit(:reset_password_token, :password, :password_confirmation)
  end
end