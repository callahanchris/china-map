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
