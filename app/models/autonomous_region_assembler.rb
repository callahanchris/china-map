class AutonomousRegionAssembler
  include RegionAssembler

  def assign_lat_lng
    if region.name != "Tibet"
      region.latitude = page.search("span.latitude")[0].text
      region.longitude = page.search("span.longitude")[0].text
    end
  end
end
