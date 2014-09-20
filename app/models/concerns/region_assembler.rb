module RegionAssembler
  include JVectorable
  attr_reader :region, :page

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
