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
      
      if province.name != "Tibet Autonomous Region"
        province.latitude = page.search("span.latitude")[0].text
        province.longitude = page.search("span.longitude")[0].text
      end

      if !%w{ Beijing Chongqing Shanghai Tianjin }.include?(province.name)
        province.capital = page.search("tr.mergedtoprow a")[0].text
      end


      province.area_km_sq = page.search("tr.mergedrow")
                              .select {|t| t.text.match(/km2/i) }
                              .first.text.split(' ')[1]
                              .gsub(',', '')[0..-5].to_i

      province.population = page.search("tr.mergedrow")
                              .select {|tr| tr.text.match(/\d{3},\d{3}\n/) }
                              .first.text.split(' ')[1]
                              .gsub(',', '').to_i

      # Consider updating to more recent GDP data:
      # http://en.wikipedia.org/wiki/List_of_Chinese_administrative_divisions_by_GDP

      # There is an error in the GDP listing on the Jiangxi wiki page http://en.wikipedia.org/wiki/Jiangxi
      if province.name == "Chongqing"
        if page.search("tr.mergedrow td")[12].text.split(' ')[2].match(/trillion/)
          province.gdp_cny = (page.search("tr.mergedrow td")[12].text.split(' ')[1].to_f * 1_000_000_000_000).to_i
        else
          province.gdp_cny = (page.search("tr.mergedrow td")[12].text.split(' ')[1].to_f * 1_000_000_000).to_i
        end
      elsif province.name == "Shanghai"
        if page.search("tr.mergedrow td")[16].text.split(' ')[0].match(/trillion/)
          province.gdp_cny = (page.search("tr.mergedrow td")[16].text.split(' ')[0][3..6].to_f * 1_000_000_000_000).to_i
        else
          province.gdp_cny = (page.search("tr.mergedrow td")[16].text.split(' ')[0][3..6].to_f * 1_000_000_000).to_i
        end
      elsif province.name == "Tianjin"
        if page.search("tr.mergedrow td")[14].text.split(' ')[0].match(/trillion/)
          province.gdp_cny = (page.search("tr.mergedrow td")[14].text.split(' ')[0][3..6].to_f * 1_000_000_000_000).to_i
        else
          province.gdp_cny = (page.search("tr.mergedrow td")[14].text.split(' ')[0][3..6].to_f * 1_000_000_000).to_i
        end
      else
        if page.search("tr.mergedtoprow td")[1].text.split(' ')[2].match(/trillion/) || province.name == "Jiangxi"
          province.gdp_cny = (page.search("tr.mergedtoprow td")[1].text.split(' ')[1].to_f * 1_000_000_000_000).to_i
        else
          province.gdp_cny = (page.search("tr.mergedtoprow td")[1].text.split(' ')[1].to_f * 1_000_000_000).to_i
        end
      end

      if province.name == "Guangdong"
        if page.search("tr.mergedtoprow td")[1].text.split(' ')[4].match(/trillion/)
          province.gdp_usd = (page.search("tr.mergedtoprow td")[1].text.split(' ')[3].to_f * 1_000_000_000_000).to_i + 1
        else
          province.gdp_usd = (page.search("tr.mergedtoprow td")[1].text.split(' ')[3].to_f * 1_000_000_000).to_i + 1
        end
      elsif province.name == "Chongqing"
        if page.search("tr.mergedrow td")[12].text.split(' ')[5].match(/trillion/)
          province.gdp_usd = (page.search("tr.mergedrow td")[12].text.split(' ')[3].to_f * 1_000_000_000_000).to_i + 1
        else
          province.gdp_usd = (page.search("tr.mergedrow td")[12].text.split(' ')[3].to_f * 1_000_000_000).to_i + 1
        end
      elsif province.name == "Shanghai"
        if page.search("tr.mergedrow td")[16].text.split(' ')[1].match(/trillion/)
          province.gdp_usd = (page.search("tr.mergedrow td")[16].text.split(' ')[1][3..8].to_f * 1_000_000_000_000).to_i
        else
          province.gdp_usd = (page.search("tr.mergedrow td")[16].text.split(' ')[1][3..8].to_f * 1_000_000_000).to_i
        end
      elsif province.name == "Tianjin"
        if page.search("tr.mergedrow td")[14].text.split(' ')[1].match(/trillion/)
          province.gdp_usd = (page.search("tr.mergedrow td")[14].text.split(' ')[1][4..9].to_f * 1_000_000_000_000).to_i
        else
          province.gdp_usd = (page.search("tr.mergedrow td")[14].text.split(' ')[1][4..9].to_f * 1_000_000_000).to_i
        end
      else
        if page.search("tr.mergedtoprow td")[1].text.split(' ')[5].match(/trillion/)
          province.gdp_usd = (page.search("tr.mergedtoprow td")[1].text.split(' ')[4].to_f * 1_000_000_000_000).to_i
        else
          province.gdp_usd = (page.search("tr.mergedtoprow td")[1].text.split(' ')[4].to_f * 1_000_000_000).to_i
        end
      end
    end
  end
end
