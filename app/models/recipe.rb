class Recipe < ApplicationRecord
  belongs_to :user

  scope :published, -> { where(is_public: true) }

  has_many :recipe_ingredients, -> { order(:position) }, dependent: :destroy, inverse_of: :recipe
  has_many :ingredients, through: :recipe_ingredients

  accepts_nested_attributes_for :recipe_ingredients,
    allow_destroy: true,
    reject_if: proc { |attrs|
      next false if attrs["id"].present?

      attrs["ingredient_id"].blank? &&
        attrs["amount"].to_s.strip.blank? &&
        attrs["unit"].to_s.strip.blank?
    }

  serialize :tags, type: Array, coder: JSON
  serialize :steps, type: Array, coder: JSON

  validates_associated :recipe_ingredients

  before_validation :renumber_recipe_ingredient_positions

  private

  def renumber_recipe_ingredient_positions
    recipe_ingredients.reject(&:marked_for_destruction?).each_with_index do |ri, idx|
      ri.position = idx
    end
  end
end
