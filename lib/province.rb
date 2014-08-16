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
    PROVINCES.each_with_index do |province, i|
      page = Nokogiri::HTML(open(province.url))
      province.territorial_designation = page.search("span.category a.mw-redirect").text
      province.latitude = page.search("span.latitude")[0].text
      province.longitude = page.search("span.longitude")[0].text
      province.capital = page.search("tr.mergedtoprow a")[0].text

      if [1, 3].include?(i)
        province.area_km_sq = page.search("tr.mergedrow")[10].text.split(' ')[1].gsub(',', '')[0..-5].to_i
        province.population = page.search("tr.mergedrow")[12].text.split(' ')[1].gsub(',', '').to_i
      elsif i == 5
        province.area_km_sq = page.search("tr.mergedrow")[9].text.split(' ')[1].gsub(',', '')[0..-5].to_i
        province.population = page.search("tr.mergedrow")[11].text.split(' ')[1].gsub(',', '').to_i
      elsif [8, 11, 12, 15, 17, 20].include?(i)
        province.area_km_sq = page.search("tr.mergedrow")[8].text.split(' ')[1].gsub(',', '')[0..-5].to_i
        province.population = page.search("tr.mergedrow")[10].text.split(' ')[1].gsub(',', '').to_i
      else
        province.area_km_sq = page.search("tr.mergedrow")[7].text.split(' ')[1].gsub(',', '')[0..-5].to_i
        province.population = page.search("tr.mergedrow")[9].text.split(' ')[1].gsub(',', '').to_i
      end

      # Consider updating to more recent GDP data:
      # http://en.wikipedia.org/wiki/List_of_Chinese_administrative_divisions_by_GDP

      # There is an error in the GDP listing on the Jiangxi wiki page http://en.wikipedia.org/wiki/Jiangxi
      if page.search("tr.mergedtoprow td")[1].text.split(' ')[2].match(/trillion/) || province.name == "Jiangxi"
        province.gdp_cny = (page.search("tr.mergedtoprow td")[1].text.split(' ')[1].to_f * 1_000_000_000_000).to_i
      else
        province.gdp_cny = (page.search("tr.mergedtoprow td")[1].text.split(' ')[1].to_f * 1_000_000_000).to_i
      end

      if province.name != "Guangdong"
        if page.search("tr.mergedtoprow td")[1].text.split(' ')[5].match(/trillion/)
          province.gdp_usd = (page.search("tr.mergedtoprow td")[1].text.split(' ')[4].to_f * 1_000_000_000_000).to_i
        else
          province.gdp_usd = (page.search("tr.mergedtoprow td")[1].text.split(' ')[4].to_f * 1_000_000_000).to_i
        end
      else
        if page.search("tr.mergedtoprow td")[1].text.split(' ')[4].match(/trillion/)
          province.gdp_usd = (page.search("tr.mergedtoprow td")[1].text.split(' ')[3].to_f * 1_000_000_000_000).to_i + 1
        else
          province.gdp_usd = (page.search("tr.mergedtoprow td")[1].text.split(' ')[3].to_f * 1_000_000_000).to_i + 1
        end
      end
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