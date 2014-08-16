require_relative '../config/environment'

class Province
  attr_accessor :url, :name, :latitude, :longitude, :capital, 
                :area_km_sq, :population, :gdp_cny, :gdp_usd,
                :territorial_designation

  PROVINCES = []

  def initialize(url)
    self.url = url
    self.name = url[29..-1].split('_').join(' ')
    PROVINCES << self
  end

  def self.all
    PROVINCES
  end

  def self.scrape_all
    PROVINCES.each do |province|
      # next if province.name == "Taiwan" || province.name == "Tibet Autonomous Region"
      page = Nokogiri::HTML(open(province.url))
      province.territorial_designation = page.search("span.category a.mw-redirect").text
      province.latitude = page.search("span.latitude")[0].text
      province.longitude = page.search("span.longitude")[0].text
      province.capital = page.search("tr.mergedtoprow a")[0].text
      province.area_km_sq = page.search("tr.mergedrow")[7].text.split(' ')[1].gsub(',', '')[0..-5]
      province.population = page.search("tr.mergedrow")[9].text.split(' ')[1].gsub(',', '')
      province.gdp_cny = page.search("tr.mergedtoprow td")[1].text.split(' ')[1..2].join(' ')
      province.gdp_usd = page.search("tr.mergedtoprow td")[1].text.split(' ')[4..5].join(' ')
    end
  end

  def to_json
    hash = {}
    self.public_methods(false).each do |meth|
      next if meth[-1] == "=" || meth.to_s == "to_json" || meth.to_s == "url"
      hash[meth.to_s] = self.send(meth)
    end
    hash.to_json
  end

  # def self.json_feed
  #   {"Provinces" => all.map(&:to_json) }.to_json
  # end

end