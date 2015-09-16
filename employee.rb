require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'employee.sqlite3'
)

class Employee < ActiveRecord::Base
  belongs_to :department
  has_many :reviews

  def total_salary
    employees.reduce(0){|sum, employee| sum + employee.salary}
  end

  def satisfactory?
    satisfactory
  end

  def give_raise(amount)
    salary += amount
  end

end
