# encoding: UTF-8
require 'open-uri'

class ChinaScraper
  attr_accessor :region_links

  def initialize
    scrape_index
    make_regions
    scrape_all_regions
  end

  def scrape_index
    puts "Scraping the China page..."
    china_main_page = Nokogiri::HTML(open("http://en.wikipedia.org/wiki/China"))
    regions = china_main_page.search("table.navbox tr td ul li a")[0..34]
    
    self.region_links = regions.collect.with_index do |p, i|
      next if i == 22
      "http://en.wikipedia.org#{p["href"]}"
    end.compact
  end

  # Regions go up to 21, skip 22 (Taiwan), others go up to 34
  def make_regions
    region_links.each_with_index do |url, i|
      next if i == 22
      region = Region.new.tap {|r| r.url = url }
      region.save
    end
  end

  def scrape_all_regions
    Region.all.each do |region|
      puts "Scraping #{region.name}..."
      page = Nokogiri::HTML(open(region.url))
      case region.name
      when "Hong Kong", "Macau"
        SARAssembler.new(region, page).compute
      when "Beijing", "Chongqing", "Shanghai", "Tianjin"
        MunicipalityAssembler.new(region, page).compute
      when "Guangxi", "Inner Mongolia", "Ningxia", "Xinjiang", "Tibet"
        AutonomousRegionAssembler.new(region, page).compute
      else
        ProvinceAssembler.new(region, page).compute
      end 
    end
  end
end

module RegionAssembler
  attr_reader :region, :page

  JVECTOR_REGION_CODES = {
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

  def jvector_codes
    JVECTOR_REGION_CODES
  end

  def jvector_keys
    jvector_codes.keys
  end

  def initialize(region, page)
    @region, @page = region, page
  end

  def compute
    assign_territorial_designation
    assign_lat_lng
    assign_capital
    assign_area_info
    assign_gdp_usd
    assign_gdp_cny
    assign_gdp_per_cap
    assign_jvector_code
    region.save
  end

  def area_info
    @area_info ||= page.search("tr.mergedrow").select {|t| t.text.match(/km2/i) }
  end

  def monetary_info
    @monetary_info ||= page.search("tr.mergedtoprow td").find {|tr| tr.text.match(/cny/i) }.text.split(' ')
  end

  def gdp_per_cap
    @gdp_per_cap ||= page.search("tr.mergedrow td").select {|tr| tr.text.match(/cny/i) }.last.text.split(' ')
  end

  def title_caps(string)
    string.split(' ').map(&:capitalize).join(' ')
  end

  def assign_territorial_designation
    region.territorial_designation = title_caps(page.search("span.category a").text)
  end

  def assign_lat_lng
    region.latitude = page.search("span.latitude")[0].text
    region.longitude = page.search("span.longitude")[0].text
  end

  def assign_capital
    region.capital = page.search("tr.mergedtoprow a")[0].text
  end

  def assign_area_info
    # region.area_km_sq = area_info.first.text.match(/[\d,]+/).to_s.gsub(',', '').to_i
    region.area_km_sq = area_info.first.text.split(/\s| /)[3].gsub(',', '').to_i
    region.population_density = area_info.last.text.split(/\s| |\//)[3].gsub(',', '').to_i
    region.population = page.search("tr.mergedrow").find {|tr| tr.text.match(/\d{3},\d{3}\n/) }.text.split(' ')[1].gsub(',', '').to_i
  end

  def assign_gdp_cny
  # There is an error in the GDP listing on the Jiangxi wiki page http://en.wikipedia.org/wiki/Jiangxi
    if monetary_info[2].match(/trillion/) || region.name == "Jiangxi"
      region.gdp_cny = (monetary_info[1].to_f * 1_000_000_000_000).to_i
    else
      region.gdp_cny = (monetary_info[1].to_f * 1_000_000_000).to_i
    end
  end

  def assign_gdp_usd
    if monetary_info[5].match(/trillion/)
      region.gdp_usd = (monetary_info[4].to_f * 1_000_000_000_000).to_i
    else
      region.gdp_usd = (monetary_info[4].to_f * 1_000_000_000).to_i
    end
  end

  def assign_gdp_per_cap
    region.gdp_per_capita = gdp_per_cap[3].gsub(',', '').to_i
  end

  def assign_jvector_code
    region.jvector_code = jvector_codes[region.name]
  end
end

class ProvinceAssembler
  include RegionAssembler

  def monetary_info
    if region.name == "Guangdong"
      @monetary_info ||= page.search("tr.mergedtoprow td").find {|tr| tr.text.match(/cny/i) }.text.split(/\s| |\$/i)
    else
      @monetary_info ||= page.search("tr.mergedtoprow td").find {|tr| tr.text.match(/cny/i) }.text.split(' ')
    end
  end

  def gdp_per_cap
    if %w{ Guangdong Hubei }.include?(region.name)
      @gdp_per_cap ||= page.search("tr.mergedrow td").find {|tr| tr.text.match(/cny/i) }.text.split(/\s|\$/)
    else
      @gdp_per_cap ||= page.search("tr.mergedrow td").select {|tr| tr.text.match(/cny/i) }.last.text.split(' ')
    end
  end
end

class AutonomousRegionAssembler
  include RegionAssembler

  def assign_lat_lng
    if region.name != "Tibet"
      region.latitude = page.search("span.latitude")[0].text
      region.longitude = page.search("span.longitude")[0].text
    end
  end
end

class MunicipalityAssembler
  include RegionAssembler

  def monetary_info
    if %w{ Beijing Chongqing }.include?(region.name)
      @monetary_info ||= page.search("tr.mergedrow td").find {|tr| tr.text.match(/cny/i) }.text.split(/\s| /)
    else %w{ Shanghai Tianjin }.include?(region.name)
      @monetary_info ||= page.search("tr.mergedrow td").find {|tr| tr.text.match(/cny/i) }.text.split(/\s| |cny|usd|\$/i)
    end
  end

  def gdp_per_cap
    if region.name == "Shanghai"
      @gdp_per_cap ||= page.search("tr.mergedrow td").select {|tr| tr.text.match(/cny/i) }.last.text.split(/\s|\$|US/)
    elsif region.name == "Tianjin"
      @gdp_per_cap ||= page.search("tr.mergedrow td").select {|tr| tr.text.match(/cny/i) }.last.text.split(/\s|\)/)
    else
      @gdp_per_cap ||= page.search("tr.mergedrow td").select {|tr| tr.text.match(/cny/i) }.last.text.split(' ')
    end
  end

  def assign_capital
  end
end

class SARAssembler
  include RegionAssembler

  def monetary_info
    @monetary_info ||= page.search("tr.mergedrow td").select {|tr| tr.text.match(/\$/) }[1].text.split(/\s|\$/)
  end

  def gdp_per_cap
    @gdp_per_cap ||= page.search("tr.mergedbottomrow td").select {|tr| tr.text.match(/\$/) }.last.text.split(/\s|\$|\[/)
  end

  def assign_territorial_designation
    region.territorial_designation = title_caps(page.search("tr td a").find {|a| a.text.match(/special/i) }.attributes["title"].value)
  end

  def assign_capital
  end

  def assign_area_info
    region.area_km_sq = area_info.first.text.split(/\s| /)[4].gsub(',', '').to_i
    region.population_density = page.search("tr.mergedbottomrow").select {|t| t.text.match(/km2/i) }.first.text.split(/\s|\[/)[2].gsub(',', '').to_i
    region.population = page.search("tr.mergedrow td").find {|td| td.text.match(/\d{3},\d{3}/) }.text.gsub(',', '').split(/\[/).first.to_i
  end

  def assign_gdp_usd
    if monetary_info[2].match(/trillion/)
      region.gdp_usd = (monetary_info[1].to_f * 1_000_000_000_000).to_i
    else
      region.gdp_usd = (monetary_info[1].to_f * 1_000_000_000).to_i
    end
  end

  def assign_gdp_cny
  end

  def assign_gdp_per_cap
    region.gdp_per_capita = gdp_per_cap[1].gsub(',', '').to_i
  end

  def assign_jvector_code
  end
end

ChinaScraper.new
