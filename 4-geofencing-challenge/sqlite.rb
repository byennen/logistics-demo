ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :feights do |table|
    table.column :carrier, :string
  end
  create_table :stops do |table|
    table.column :feight_id, :integer
    table.column :address_line_1, :string
    table.column :city, :string
    table.column :state, :string
    table.column :zipcode, :string
    table.column :country, :string
    table.column :latitude, :string
    table.column :longitude, :string
    table.column :visited, :boolean
    table.column :type, :string
  end
end
