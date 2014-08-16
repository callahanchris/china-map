require_relative '../config/environment'

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

  #Provinces go up to 21, skip 22, others go up to 34
  def make_provinces
    province_links[0..21].each do |url|
      Province.new(url)
    end
  end
end