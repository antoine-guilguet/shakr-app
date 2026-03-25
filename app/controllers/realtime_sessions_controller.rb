class RealtimeSessionsController < ApplicationController
  before_action :authenticate_user!

  def create
    result = Openai::RealtimeClientSecret.call
    render json: result, status: :created
  rescue Openai::RealtimeClientSecret::Error => e
    render json: { error: e.message }, status: :bad_gateway
  end
end
