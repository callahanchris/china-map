class Province < ActiveRecord::Base

  before_create :assign_name_from_url

  def assign_name_from_url
    self.name = url[29..-1].split('_').join(' ')
  end

end
