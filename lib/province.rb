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

      if province.name == "Guangxi"
        binding.pry
      end

      if %w{ Hong\ Kong Macau }.include?(province.name)
        province.territorial_designation = page.search("tr td a").find {|a| a.text.match(/special/i) }.text.split(" of ").first
      else
        province.territorial_designation = page.search("span.category a").text
      end

      province.territorial_designation = province.territorial_designation.split(' ').map(&:capitalize).join(' ')
      
      if province.name != "Tibet Autonomous Region"
        province.latitude = page.search("span.latitude")[0].text
        province.longitude = page.search("span.longitude")[0].text
      end

      if !%w{ Beijing Chongqing Shanghai Tianjin Hong\ Kong Macau }.include?(province.name)
        province.capital = page.search("tr.mergedtoprow a")[0].text
      end

      if %w{ Hong\ Kong Macau }.include?(province.name)
        province.area_km_sq = page.search("tr.mergedrow").find {|t| t.text.match(/km2/i) }.text.split(' ')[2].gsub(',', '')[0..-5].to_i
        province.population = page.search("tr.mergedrow td").find {|td| td.text.match(/\d{3},\d{3}/) }.text.gsub(',', '').split(/\[/).first.to_i
      else
        province.area_km_sq = page.search("tr.mergedrow").find {|t| t.text.match(/km2/i) }.text.split(' ')[1].gsub(',', '')[0..-5].to_i
        province.population = page.search("tr.mergedrow").find {|tr| tr.text.match(/\d{3},\d{3}\n/) }.text.split(' ')[1].gsub(',', '').to_i
      end

      # Consider updating to more recent GDP data:
      # http://en.wikipedia.org/wiki/List_of_Chinese_administrative_divisions_by_GDP

      # There is an error in the GDP listing on the Jiangxi wiki page http://en.wikipedia.org/wiki/Jiangxi
      
      if %w{ Beijing Chongqing }.include?(province.name)
        monetary_info = page.search("tr.mergedrow td").find {|tr| tr.text.match(/cny/i) }.text.split(/\s| /)
      elsif %w{ Shanghai Tianjin }.include?(province.name)
        monetary_info = page.search("tr.mergedrow td").find {|tr| tr.text.match(/cny/i) }.text.split(/\s| |cny|usd|\$/i)
      elsif %w{ Guangdong }.include?(province.name)
        monetary_info = page.search("tr.mergedtoprow td").find {|tr| tr.text.match(/cny/i) }.text.split(/\s| |\$/i)
      elsif %w{ Hong\ Kong Macau }.include?(province.name)
        monetary_info = page.search("tr.mergedrow td").select {|tr| tr.text.match(/\$/) }[1].text.split(/\s|\$/)
      else
        monetary_info = page.search("tr.mergedtoprow td").find {|tr| tr.text.match(/cny/i) }.text.split(' ')
      end

      if %w{ Hong\ Kong Macau }.include?(province.name)
        if monetary_info[2].match(/trillion/)
          province.gdp_usd = (monetary_info[1].to_f * 1_000_000_000_000).to_i
        else
          province.gdp_usd = (monetary_info[1].to_f * 1_000_000_000).to_i
        end
      else
        if monetary_info[2].match(/trillion/) || province.name == "Jiangxi"
          province.gdp_cny = (monetary_info[1].to_f * 1_000_000_000_000).to_i
        else
          province.gdp_cny = (monetary_info[1].to_f * 1_000_000_000).to_i
        end

        if monetary_info[5].match(/trillion/)
          province.gdp_usd = (monetary_info[4].to_f * 1_000_000_000_000).to_i
        else
          province.gdp_usd = (monetary_info[4].to_f * 1_000_000_000).to_i
        end
      end
    end
  end
end
