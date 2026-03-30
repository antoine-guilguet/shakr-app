module Recipes
  class UpdateOrForkFromAgent
    Result = Struct.new(:recipe, :forked, keyword_init: true)

    def self.call(user:, input:)
      new(user:, input:).call
    end

    def initialize(user:, input:)
      @user = user
      @input = input.to_h
    end

    def call
      recipe_id = @input["recipe_id"] || @input[:recipe_id]
      raise CreateFromAgent::ValidationError.new("recipe_id is required") if recipe_id.blank?

      recipe = Recipe.includes(recipe_ingredients: :ingredient).find_by(id: recipe_id)
      raise CreateFromAgent::ValidationError.new("Recipe not found.") unless recipe

      unless recipe.is_public? || recipe.user_id == @user.id
        raise CreateFromAgent::ValidationError.new("You cannot access this recipe.")
      end

      if recipe.user_id == @user.id
        Result.new(recipe: update_owned!(recipe), forked: false)
      else
        Result.new(recipe: fork!(recipe), forked: true)
      end
    end

    private

    def update_owned!(recipe)
      merged = merge_with_base(recipe, @input)
      attributes = CreateFromAgent.attributes_from_input(merged)

      Recipe.transaction do
        recipe.assign_attributes(
          name: attributes[:name],
          description: attributes[:description],
          tags: attributes[:tags],
          steps: attributes[:steps],
          glassware: attributes[:glassware],
          garnish: attributes[:garnish]
        )
        if @input.key?("is_public") || @input.key?(:is_public)
          recipe.is_public = attributes[:is_public]
        end

        recipe.recipe_ingredients.destroy_all
        attributes[:ingredients].each_with_index do |ingredient_attrs, index|
          ingredient = Ingredient.find_or_create_by_name!(ingredient_attrs[:name], kind: :mixer)
          recipe.recipe_ingredients.build(
            ingredient: ingredient,
            amount: ingredient_attrs[:quantity],
            unit: ingredient_attrs[:unit],
            position: index
          )
        end

        recipe.save!
      end

      recipe
    rescue ActiveRecord::RecordInvalid => e
      details = e.record.errors.full_messages
      raise CreateFromAgent::ValidationError.new("Recipe could not be saved.", details: details)
    end

    def fork!(source)
      merged = merge_with_base(source, @input)
      merged["is_public"] = false unless input_has_is_public?(@input)

      CreateFromAgent.call(user: @user, input: merged)
    end

    def input_has_is_public?(input)
      input.key?("is_public") || input.key?(:is_public)
    end

    def merge_with_base(recipe, raw_input)
      incoming = raw_input.stringify_keys.except("recipe_id")
      base_input_hash(recipe).merge(incoming)
    end

    def base_input_hash(recipe)
      {
        "name" => recipe.name,
        "description" => recipe.description,
        "tags" => recipe.tags,
        "steps" => Array(recipe.steps),
        "glassware" => recipe.glassware,
        "garnish" => recipe.garnish,
        "is_public" => recipe.is_public?,
        "ingredients" => recipe.recipe_ingredients.sort_by(&:position).map do |ri|
          {
            "name" => ri.ingredient.name,
            "quantity" => ri.amount.to_f,
            "unit" => ri.unit
          }
        end
      }
    end
  end
end
