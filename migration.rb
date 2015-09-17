require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'employee.sqlite3' 
)

class EmployeeMigration < ActiveRecord::Migration
  def change
    create_table :departments do |t|
      t.string :name
      t.timestamps null: false
    end

    create_table :employees do |t|
      t.integer :department_id
      t.string :name
      t.integer :salary
      t.string :email
      t.string :phone
      t.boolean :satisfactory, default: true
      t.timestamps null: false
    end

    create_table :reviews do |t|
      t.integer :employee_id
      t.text :review
      t.timestamps null: false
    end
  end
end
