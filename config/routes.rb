Rails.application.routes.draw do
	namespace :api , defaults: { format: 'json' } do
		namespace :v1 do 
			devise_for :user, controllers: {
				sessions: 'api/v1/user/sessions',
				registrations: 'api/v1/user/registrations',

			}
			resources :tweets, only:[:create,:destroy]
			get 'follow', to: 'users#follow'
			get 'unfollow', to: 'users#unfollow'
			get 'followers_tweets', to: 'users#followers_tweets'
			get 'user_profile', to: 'users#user_profile'
		end
	end
end


