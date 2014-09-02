# encoding: UTF-8
require 'open-uri'

class ChinaScraper
  attr_accessor :province_links

  JVECTOR_PROVINCE_CODES = {
    "Anhui" => "CN-34",
    "Beijing" => "CN-11",
    "Chongqing" => "CN-50",
    "Fujian" => "CN-35",
    "Gansu" => "CN-62",
    "Guangdong" => "CN-44",
    "Guangxi" => "CN-45",
    "Guizhou" => "CN-52",
    "Hainan" => "CN-46",
    "Hebei" => "CN-13",
    "Heilongjiang" => "CN-23",
    "Henan" => "CN-41",
    "Hubei" => "CN-42",
    "Hunan" => "CN-43",
    "Inner Mongolia" => "CN-15",
    "Jiangsu" => "CN-32",
    "Jiangxi" => "CN-36",
    "Jilin" => "CN-22",
    "Liaoning" => "CN-21",
    "Ningxia" => "CN-64",
    "Qinghai" => "CN-63",
    "Shaanxi" => "CN-61",
    "Shandong" => "CN-37",
    "Shanghai" => "CN-31",
    "Shanxi" => "CN-14",
    "Sichuan" => "CN-51",
    "Tianjin" => "CN-12",
    "Xinjiang" => "CN-65",
    "Tibet" => "CN-54",
    "Yunnan" => "CN-53",
    "Zhejiang" => "CN-33"
  }

  def self.jvector_codes
    JVECTOR_PROVINCE_CODES
  end

  def self.jvector_keys
    jvector_codes.keys
  end

  def initialize
    scrape_index
    make_provinces
    scrape_all_provinces
  end

  def scrape_index
    puts "Scraping the China page..."
    china_main_page = Nokogiri::HTML(open("http://en.wikipedia.org/wiki/China"))
    provinces = china_main_page.search("table.navbox tr td ul li a")[0..34]
    
    self.province_links = provinces.collect.with_index do |p, i|
      next if i == 22
      "http://en.wikipedia.org#{p["href"]}"
    end.compact
  end

  # Provinces go up to 21, skip 22 (Taiwan), others go up to 34
  def make_provinces
    province_links.each_with_index do |url, i|
      next if i == 22
      province = Province.new.tap {|p| p.url = url }
      province.save
    end
  end

  def scrape_all_provinces
    Province.all.each do |province|
      puts "Scraping #{province.name}..."
      page = Nokogiri::HTML(open(province.url))

      if %w{ Hong\ Kong Macau }.include?(province.name)
        province.territorial_designation = page.search("tr td a").find {|a| a.text.match(/special/i) }.text.split(" of ").first
      else
        province.territorial_designation = page.search("span.category a").text
      end

      province.territorial_designation = province.territorial_designation.split(' ').map(&:capitalize).join(' ')
      
      if province.name != "Tibet"
        province.latitude = page.search("span.latitude")[0].text
        province.longitude = page.search("span.longitude")[0].text
      end

      if !%w{ Beijing Chongqing Shanghai Tianjin Hong\ Kong Macau }.include?(province.name)
        province.capital = page.search("tr.mergedtoprow a")[0].text
      end
      
      area_info = page.search("tr.mergedrow").select {|t| t.text.match(/km2/i) }

      if %w{ Hong\ Kong Macau }.include?(province.name)
        province.area_km_sq = area_info.first.text.split(/\s| /)[4].gsub(',', '').to_i
        province.population_density = page.search("tr.mergedbottomrow").select {|t| t.text.match(/km2/i) }.first.text.split(/\s|\[/)[2].gsub(',', '').to_i
        province.population = page.search("tr.mergedrow td").find {|td| td.text.match(/\d{3},\d{3}/) }.text.gsub(',', '').split(/\[/).first.to_i
      else
        province.area_km_sq = area_info.first.text.split(/\s| /)[3].gsub(',', '').to_i
        province.population_density = area_info.last.text.split(/\s| |\//)[3].gsub(',', '').to_i
        province.population = page.search("tr.mergedrow").find {|tr| tr.text.match(/\d{3},\d{3}\n/) }.text.split(' ')[1].gsub(',', '').to_i
      end

      # Consider updating to more recent GDP data:
      # http://en.wikipedia.org/wiki/List_of_Chinese_administrative_divisions_by_GDP

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
      # There is an error in the GDP listing on the Jiangxi wiki page http://en.wikipedia.org/wiki/Jiangxi
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

      if %w{ Guangdong Hubei }.include?(province.name)
        gdp_per_cap = page.search("tr.mergedrow td").find {|tr| tr.text.match(/cny/i) }.text.split(/\s|\$/)
      elsif %w{ Shanghai }.include?(province.name)
        gdp_per_cap = page.search("tr.mergedrow td").select {|tr| tr.text.match(/cny/i) }.last.text.split(/\s|\$|US/)
      elsif %w{ Tianjin }.include?(province.name)
        gdp_per_cap = page.search("tr.mergedrow td").select {|tr| tr.text.match(/cny/i) }.last.text.split(/\s|\)/)
      elsif %w{ Hong\ Kong Macau }.include?(province.name)
        gdp_per_cap = page.search("tr.mergedbottomrow td").select {|tr| tr.text.match(/\$/) }.last.text.split(/\s|\$|\[/)
      else
        gdp_per_cap = page.search("tr.mergedrow td").select {|tr| tr.text.match(/cny/i) }.last.text.split(' ')
      end
      
      if %w{ Hong\ Kong Macau }.include?(province.name)
        province.gdp_per_capita = gdp_per_cap[1].gsub(',', '').to_i
      else
        province.gdp_per_capita = gdp_per_cap[3].gsub(',', '').to_i
      end

      if self.class.jvector_keys.include?(province.name)
        province.jvector_code = self.class.jvector_codes[province.name]
      end

      province.save
    end
  end
end

ChinaScraper.new
