class RecipesController < ApplicationController
  before_action :authenticate_user!

  def index
    render :new
  end

  def new
  end
end

