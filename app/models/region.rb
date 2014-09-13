class Region < ActiveRecord::Base

  before_create :assign_name_from_url

  def assign_name_from_url
    self.name = url[29..-1].split('_').join(' ')
    self.name.sub!(' Autonomous Region', '') if self.name.ends_with?(' Autonomous Region')
  end

end
