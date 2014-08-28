class CreateProvinces < ActiveRecord::Migration
  def change
    create_table :provinces do |t|
      t.string :name
      t.string :url
      t.string :territorial_designation
      t.string :latitude
      t.string :longitude
      t.string :capital
      t.integer :area_km_sq
      t.integer :population
      t.integer :gdp_cny
      t.integer :gdp_usd
      t.string :jvector_code

      t.timestamps
    end
  end
end
