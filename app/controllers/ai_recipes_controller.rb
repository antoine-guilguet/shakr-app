class AiRecipesController < ApplicationController
  before_action :authenticate_user!

  def create
    @recipe = RecipeGenerator.call(
      prompt: ai_recipe_params[:prompt],
      user: current_user
    )

    render "recipes/new", status: :ok
  rescue RecipeGenerator::Error => e
    flash.now[:alert] = e.message
    render "recipes/new", status: :unprocessable_entity
  end

  private

  def ai_recipe_params
    params.require(:ai_recipe).permit(:prompt)
  end
end

