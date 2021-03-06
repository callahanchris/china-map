# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140828153845) do

  create_table "regions", force: true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "territorial_designation"
    t.string   "latitude"
    t.string   "longitude"
    t.string   "capital"
    t.integer  "area_km_sq"
    t.integer  "population"
    t.integer  "population_density"
    t.integer  "gdp_cny"
    t.integer  "gdp_usd"
    t.integer  "gdp_per_capita"
    t.string   "jvector_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
