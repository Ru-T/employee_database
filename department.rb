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
    # getting_raise = self.employees.where(satisfactory: true)
    # getting_raise.each {|e| e.give_raise(total_amount / getting_raise.length})
  end

  def total_employees
    employees.count
  end

  def least_paid
    employees.order("salary").first
  end

  def alphabetize_names
    employees.order("name").to_a
  end

  def salary_above_average
    employees.where("employees.salary > 15")
    ## NEED TO FIX THE ABOVE TO ACTUALLY WORK
  end

  def palindrome
    employees.where(name.downcase == name.downcase.reverse).to_a
    ## NEED TO FIX THE ABOVE TO ACTUALLY WORK
  end


  def most_employees
    self.order(employees.count).first
  end
  #
  # def move_employees
  #
  # end

end
