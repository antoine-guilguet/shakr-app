class RecipesController < ApplicationController
  before_action :authenticate_user!, except: %i[ show ]

  before_action :set_recipe_for_show, only: %i[ show ]
  before_action :set_recipe_for_owner, only: %i[ edit update destroy ]

  def index
    @visibility_filter = params[:visibility].presence_in(%w[public private]) || "all"

    @recipes = case @visibility_filter
    when "public"
      Recipe.where(is_public: true).order(updated_at: :desc)
    when "private"
      Recipe.where(user_id: current_user.id).order(updated_at: :desc)
    else
      Recipe
        .where(user_id: current_user.id)
        .or(Recipe.where(is_public: true))
        .distinct
        .order(updated_at: :desc)
    end
  end

  def new
    @recipe = Recipe.new
    @recipe.recipe_ingredients.build
  end

  def create
    @recipe = Recipe.new(recipe_params.merge(user_id: current_user.id))

    if @recipe.save
      redirect_to @recipe, notice: "Recipe created successfully."
    else
      ensure_recipe_ingredient_rows
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
    ensure_recipe_ingredient_rows
  end

  def update
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: "Recipe updated successfully."
    else
      ensure_recipe_ingredient_rows
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe.destroy
    redirect_to recipes_path, notice: "Recipe deleted successfully."
  end

  private

  def set_recipe_for_show
    @recipe = Recipe.find_by(id: params[:id])
    unless @recipe
      redirect_to root_path, alert: "Recipe not found."
      return
    end

    return if @recipe.is_public?
    return if user_signed_in? && @recipe.user_id == current_user.id

    redirect_to root_path, alert: "Recipe not found."
  end

  def set_recipe_for_owner
    @recipe = Recipe.find_by(id: params[:id], user_id: current_user.id)
    return if @recipe

    redirect_to recipes_path, alert: "Recipe not found."
  end

  def ensure_recipe_ingredient_rows
    return if @recipe.recipe_ingredients.reject(&:marked_for_destruction?).any?

    @recipe.recipe_ingredients.build
  end

  def recipe_params
    permitted = params.require(:recipe).permit(
      :name,
      :description,
      :glassware,
      :garnish,
      :tags,
      :steps,
      :is_public,
      recipe_ingredients_attributes: [
        :id,
        :ingredient_id,
        :amount,
        :unit,
        :position,
        :_destroy
      ]
    )

    attrs = {
      name: permitted[:name],
      description: permitted[:description],
      glassware: permitted[:glassware],
      garnish: permitted[:garnish],
      tags: parse_tags(permitted[:tags]),
      steps: parse_steps(permitted[:steps]),
      recipe_ingredients_attributes: permitted[:recipe_ingredients_attributes]
    }
    attrs[:is_public] = permitted[:is_public] if permitted.key?(:is_public)
    attrs
  end

  def parse_tags(tags_string)
    return [] if tags_string.blank?

    tags_string
      .split(",")
      .map(&:strip)
      .reject(&:blank?)
  end

  def parse_steps(steps_string)
    return [] if steps_string.blank?

    steps_string
      .lines
      .map(&:strip)
      .reject(&:blank?)
  end
end
