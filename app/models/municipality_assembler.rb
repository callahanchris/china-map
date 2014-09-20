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
