class Ingredient < ApplicationRecord
  has_many :recipe_ingredients, dependent: :restrict_with_error
  has_many :recipes, through: :recipe_ingredients

  enum :kind, {
    spirit: 1,
    liqueur: 2,
    juice: 3,
    syrup: 4,
    mixer: 5,
    bitters: 6,
    garnish: 7,
    other: 8
  }, default: :spirit

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  def self.find_or_create_by_name!(name, kind: :mixer)
    n = name.to_s.strip
    raise ArgumentError, "Ingredient name can't be blank" if n.blank?

    where("lower(trim(name)) = ?", n.downcase).first_or_create!(name: n, kind: kind)
  end
end
