class Api::V1::BaseController < ApplicationController
  rescue_from ActionController::ParameterMissing, with: :param_missing
  around_action :handle_exceptions
  skip_before_action :verify_authenticity_token

  rescue_from ActionController::ParameterMissing do |exception|
    respond_to do |format|
      format.html { redirect_to root_url }
      format.json {
        render json: {
            success: false,
            message: exception.message
        }, status: :unprocessable_entity
      }
    end
  end

  respond_to :json

  def render_object object, additional_options = {}
    class_name = additional_options[:class_name] || object.class.name
    serializer = "Api::V1::#{class_name}Serializer".constantize
    object_key = class_name.downcase
    additional_options.delete(:class_name)
    if object
      render json: {message: 'success',
                    data: {object_key.to_sym => serializer.new(object)}.merge(additional_options)
      },
             status: :ok
    else
      render json: {
          message: 'success',
          data: {object_key.to_sym => {}}.merge(additional_options)
      }, status: :ok
    end
  end

  def render_collection collection, model, additional_options = {}, serializer_options = {}
    serializer = "Api::V1::#{model.name}Serializer".constantize
    object_key = model.name.underscore.pluralize.downcase
    render json: {message: 'success',
                  data: {object_key.to_sym => collection_serializer.new(collection, serializer: serializer, options: serializer_options)}.merge(additional_options)},
           status: :ok
  end

  def render_error message
    message = message.is_a?(Array) ? message.first : message
    render json: {message: "failed", error: message}, status: :unprocessable_entity and return
  end

  def render_message message
    render json: {message: "success", data: {message: message}}, status: :ok
  end

  def render_json data
    render json: {message: "success", data: data}, status: :ok
  end

  def render_success
    render status: :ok, json: {
        message: 'success'
    }
  end

  def collection_serializer
    ActiveModel::Serializer::CollectionSerializer
  end

  def current_user
    @current_user ||= begin
      if request.headers['auth-token'].present?
        token = AuthenticationToken.where(:body => request.headers['auth-token']).first
        if token
          token.user
        end
      end
    end
  end

  protected

  def param_missing(exception)
    render json: {
        success: false,
        message: exception.message
    }, status: :unprocessable_entity
  end


  private

  def handle_exceptions
    begin
      yield
    rescue ActiveRecord::RecordNotFound => e
      render json: {message: "failed", error: "#{ e.model.constantize } not found"}, status: :not_found
    rescue ActiveRecord::RecordInvalid => e
      render json: {message: "failed", error: e.record.errors}, status: :unprocessable_entity
    rescue ArgumentError => e
      render json: {message: "failed", error: e.message}, status: 400
    end
  end

  def unprocessable_entity_handler record
    render json: {message: "failed", error: record.errors}, status: :unprocessable_entity
  end

end