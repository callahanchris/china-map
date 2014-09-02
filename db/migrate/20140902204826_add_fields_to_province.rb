class AddFieldsToProvince < ActiveRecord::Migration
  def change
    add_column :provinces, :population_density, :integer
    add_column :provinces, :gdp_per_capita, :integer
    add_column :provinces, :iso_code, :string
  end
end
