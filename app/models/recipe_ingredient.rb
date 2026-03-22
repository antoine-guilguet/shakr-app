class RecipeIngredient < ApplicationRecord
  UNITS = %w[ml cl oz dash piece tsp].freeze

  belongs_to :recipe, inverse_of: :recipe_ingredients
  belongs_to :ingredient, inverse_of: :recipe_ingredients

  validates :unit, presence: true, inclusion: { in: UNITS }
  validates :position, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :amount, presence: true, numericality: { greater_than: 0 }

  before_validation :assign_position, on: :create, if: -> { position.nil? }

  private

  def assign_position
    self.position = (recipe.recipe_ingredients.map(&:position).compact.max || -1) + 1
  end
end
