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
