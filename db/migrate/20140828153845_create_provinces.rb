class CreateProvinces < ActiveRecord::Migration
  def change
    create_table :provinces do |t|
      t.string :name
      t.string :url
      t.string :territorial_designation
      t.string :latitude
      t.string :longitude
      t.string :capital
      t.column :area_km_sq, 'bigint'
      t.column :population, 'bigint'
      t.integer :population_density
      t.column :gdp_cny, 'bigint'
      t.column :gdp_usd, 'bigint'
      t.integer :gdp_per_capita
      t.string :jvector_code

      t.timestamps
    end
  end
end
