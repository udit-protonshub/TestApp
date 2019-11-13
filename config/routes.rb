Rails.application.routes.draw do
	namespace :api , defaults: { format: 'json' } do
		namespace :v1 do 
			devise_for :user, controllers: {
				sessions: 'api/v1/user/sessions',
				registrations: 'api/v1/user/registrations',

			}
      resources :registrations, only: [] do
        collection do
          post :sign_up
          post :forgot_password
          post :reset_password
        end
      end
      resources :sessions, only: [] do
        collection do
          delete :destroy
          post :sign_in
        end
      end
      
      resources :users, only: [:update, :show] do
        collection do
          post :reset_home_location
        end
      end

      
		resources :tweets, only:[:create,:destroy]
		get 'follow', to: 'users#follow'
		get 'unfollow', to: 'users#unfollow'
		get 'followers_tweets', to: 'users#followers_tweets'
		get 'user_profile', to: 'users#user_profile'
	end
	end
end


