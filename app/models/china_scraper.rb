# encoding: UTF-8
require 'open-uri'

class ChinaScraper
  attr_accessor :region_links

  def run
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
