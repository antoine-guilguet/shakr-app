class ToolRegistry
  def initialize
    @tools = {}
  end

  def register(tool)
    @tools[tool.name] = tool
  end

  def fetch(name)
    @tools.fetch(name)
  end

  def definitions_for_openai
    @tools.values.map(&:definition_for_openai)
  end

  def self.default
    new.tap do |r|
      r.register(Tools::RecipesSearchTool.new)
      r.register(Tools::CreateAiRecipeTool.new)
      r.register(Tools::SaveRecipeTool.new)
      r.register(Tools::UpdateRecipeTool.new)
      r.register(Tools::UiStateUpdateTool.new)
    end
  end
end

