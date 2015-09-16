require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'employee.sqlite3'
)

class Department < ActiveRecord::Base
  has_many :employees

  def add_employee(employee)
    employees << employee
  end

  def total_salary
    employees.reduce(0){|sum, employee| sum + employee.salary}
  end

  def give_raise(total_amount)
    getting_raise = employees.select {|e| e.satisfactory?}
    getting_raise.each {|e| e.give_raise(total_amount / getting_raise.length)}
  end

  def total_employees
    employees.count #  employees.reduce(0){|sum, employee| sum + employee.salary}
  end
end
