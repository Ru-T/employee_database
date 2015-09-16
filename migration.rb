require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'db.sqlite3' #name can be whatever you want with sqlite3 suffix, and this file does not yet have to exist if you're using sqlite3
)

# class EmployeeMigration < ActiveRecord::Migration
#   def change
#     create_table :albums do |t| #don't need to specify ID, this happens automatically and auto-increments
#       t.integer :artist_id #foreign keys first, convention
#       t.string :title
#       t.integer :number_in_stock
#       t.decimal :price, precision: 5, scale: 2 #for decimal, give hash including precision (how many significant digits in the whole number) and scale (how many after decimal point)
#       t.date :released_on #use _on for signify to other developers that you're using a date type
#       t.timestamps null: false #gives you created_at and updated_at automatically
#     end
#
#     create_table :artists do |t|
#       t.string :name
#   end
# end
#
# AlbumMigration.migrate(:up) #do the change or (:down) to undo the change

#will return a ConnectionNotEstablished error if you forget to specify the filename
