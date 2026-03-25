module Agent
  class ToolsController < ApplicationController
    before_action :authenticate_user!

    def create
      tool_name = params[:name].to_s
      tool = ToolRegistry.default.fetch(tool_name)

      input = request.request_parameters
      result = tool.call(user: current_user, input:)

      render json: result
    rescue KeyError
      render json: { error: "Unknown tool." }, status: :not_found
    rescue Tools::BaseTool::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error("[Agent::ToolsController] tool=#{params[:name]} error=#{e.class} #{e.message}")
      render json: { error: "Tool execution failed." }, status: :internal_server_error
    end
  end
end

