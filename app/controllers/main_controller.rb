class MainController < ApplicationController
  def index
    @regions = Region.all
  end
end
