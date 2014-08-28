# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

class WikiScraper
  attr_accessor :province_links

  def initialize
    scrape_index
    make_provinces
  end

  def scrape_index
    china_main_page = Nokogiri::HTML(open("http://en.wikipedia.org/wiki/China"))
    provinces = china_main_page.search("table.navbox tr td ul li a")[0..34]
    
    self.province_links = provinces.collect.with_index do |p, i|
      next if i == 22
      "http://en.wikipedia.org#{p["href"]}"
    end.compact
  end

  # Provinces go up to 21, skip 22, others go up to 34
  def make_provinces
    # province_links[0..21].each do |url|
    province_links.each_with_index do |url, i|
      next if i == 22
      Province.new(url)
    end
  end
end


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
