module ApplicationHelper
  def recipes_index_filter_class(current, value)
    base = "recipes-index-filter"
    active = current == value ? " #{base}--active" : ""
    "#{base}#{active}"
  end
end
