class Api::V1::TweetsController < ApplicationController
	def create
		if  tweet = current_user.tweets.create(tweets_params)
			render json: { tweet: tweet, status: :success, message: "Tweet Created succesfully" }
		else
			render json: {  status: :success, message: "Failed to Create Tweet" }
		end
	end

	def destroy
		tweet = Tweet.find(params[:id])
		if tweet && tweet.delete
			render json: {  status: :success, message: "Tweet destroyed succesfully" }
		else
			render json: {  status: :success, message: "Failed to destroy Tweet" }
		end
	end

	private
	def tweets_params
		params.require(:tweet).permit(:content,:user_id)
	end
end
