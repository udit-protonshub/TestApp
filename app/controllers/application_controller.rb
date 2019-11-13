class ApplicationController < ActionController::Base
	#before_action :auth_token
	skip_before_action :verify_authenticity_token

  respond_to :json
end
