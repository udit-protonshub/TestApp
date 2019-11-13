class Api::V1::UsersController < Api::V1::BaseController
  include Orderable
  before_action :verify_user, except: :reset_home_location

  def update
    current_user.update_attributes!(update_params)
    render_message "User updated successfully."
  end

  def show
    render_object current_user
  end


  def user_profile
    user = current_user
    if user.present?
      render json: { user: user, followers: user.followers, following: user.following, status: :success, message: "User found successfully" }
    else
      render json: { status: :success, message: "Couldn't find user" }
    end
  end

  def follow
    unless Follow.where(user_id: params[:user_id], follower_id: current_user.id).present?
      follow = Follow.create(user_id: params[:user_id], follwer_id: current_user.id)
      render_object follow
    else
      render json: { status: :success, message: "Already following" }
    end
  end

  def unfollow
    follow = Follow.where(user_id: params[:user_id], follower_id: current_user.id)
    unless follow.present?
      if follow.first.destroy
        render json: { status: :success, message: "Unfollowed successfully" }
      else
        render json: { status: :success, message: "Failed to unfollow the user" }   
      end
    else
      render json: { status: :success, message: "You are not following this user" }   
    end
  end

  def followers_tweets
    tweets = Tweet.order(ordering_params(params)).where(user_id: current_user.following_ids)
    render_collection tweets
    if tweets
      render json: { tweets: tweets, status: :success, message: "Tweets found successfully" }
    else
      render json: { tweets: [], status: :success, message: "To tweets found" }   
    end
  end

  

  private

  def update_params
    params.require(:user).permit(:full_name, :home_address, :timezone, current_location: {}, home_location: {})
  end

  def verify_user
    if current_user != User.find(params[:id])
      render_error 'bad request.'
    end
  end

end
