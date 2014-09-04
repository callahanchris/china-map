class CreateProvinces < ActiveRecord::Migration
  def change
    create_table :provinces do |t|
      t.string :name
      t.string :url
      t.string :territorial_designation
      t.string :latitude
      t.string :longitude
      t.string :capital
      t.bigint :area_km_sq
      t.bigint :population
      t.integer :population_density
      t.bigint :gdp_cny
      t.bigint :gdp_usd
      t.integer :gdp_per_capita
      t.string :jvector_code

      t.timestamps
    end
  end
end
