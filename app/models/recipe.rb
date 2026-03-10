class Recipe < ApplicationRecord
  belongs_to :user

  serialize :tags, type: Array, coder: JSON
  serialize :ingredients, type: Array, coder: JSON
  serialize :steps, type: Array, coder: JSON
end

