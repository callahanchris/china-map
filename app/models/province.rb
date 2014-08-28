class Province < ActiveRecord::Base

  def initialize(url)
    self.url = url
    self.name = url[29..-1].split('_').join(' ')
    self.save
    super
  end

end
