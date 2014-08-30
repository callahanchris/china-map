class MainController < ApplicationController
  def index
    @provinces = Province.all
  end
end
