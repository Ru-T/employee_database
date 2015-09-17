require 'minitest/autorun'
require 'minitest/pride'
require './employee'
require './department'
require 'byebug'
require './migration'
require './reviews'
require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'employee_test.sqlite3'
)

EmployeeMigration.migrate(:down) rescue false
EmployeeMigration.migrate(:up)

class ReviewsTest < Minitest::Test

  def test_create_new_department
    assert Department.create(name: "Development")
    # assert_raises(ArgumentError) do
    #   Department.create()
    # end
    assert_raises(ArgumentError) do
      Department.create(1,2)
    end
  end

  def test_create_new_employee
    assert Employee.create(name: "Joanna", email: "jdark@example.com", phone: "515-888-4821", salary: 85000)
    assert_raises(ArgumentError) do
      Employee.create(1,2,3,4,5)
    end
    # assert_raises(ArgumentError) do
    #   Employee.create(1,2,3)
    # end
  end

  def test_add_employee_to_department
    e = Employee.create(name: "Joanna", email: "jdark@example.com", phone: "515-888-4821", salary: 85000)
    d = Department.create(name: "Development")
    d.add_employee(e)
    assert_equal e.department_id, d.id
  end

  def test_get_employee_name
    employee = Employee.create(name: "Joanna", email: "jdark@example.com", phone: "515-888-4821", salary: 85000)
    assert_equal "Joanna", employee.name
  end

  def test_get_employee_salary
    employee = Employee.create(name: "Joanna", email: "jdark@example.com", phone: "515-888-4821", salary: 85000)
    assert_equal 85000, employee.salary
  end

  def test_get_department_salary
    employee = Employee.create(name: "Joanna", email: "jdark@example.com", phone: "515-888-4821", salary: 80000)
    employee2 = Employee.create(name: "Lunk", email: "lunk@example.com", phone: "882-329-3843", salary: 150000)
    development = Department.create(name: "Development")
    development.add_employee(employee)
    development.add_employee(employee2)
    assert_equal 230000, development.total_salary
  end

  def test_employees_can_be_reviewed
    employee = Employee.create(name: "Joanna", email: "jdark@example.com", phone: "515-888-4821", salary: 80000)
    assert employee.give_review("This employee started off great. Not as impressed with her recent performance.")
  end

  def test_new_employees_should_be_satisfactory
    employee = Employee.create(name: "Joanna", email: "jdark@example.com", phone: "515-888-4821", salary: 80000)
    assert employee.satisfactory?
  end

  def test_employees_can_get_raises
    employee = Employee.create(name: "Joanna", email: "jdark@example.com", phone: "515-888-4821", salary: 80000)
    employee.give_raise(5000)
    assert_equal 85000, employee.salary
  end

  def test_whole_departments_can_get_raises
    employee = Employee.create(name: "Joanna", email: "jdark@example.com", phone: "515-888-4821", salary: 80000)
    employee2 = Employee.create(name: "Lunk", email: "lunk@example.com", phone: "882-329-3843", salary: 150000)
    employee3 = Employee.create(name: "Sanic", email: "sanic@example.com", phone: "333-444-5555", salary: 20000)
    development = Department.create(name: "Development")
    development.add_employee(employee)
    development.add_employee(employee2)
    development.give_raise(30000)
    assert_equal 95000, employee.salary # employee.reload.salary
    assert_equal 165000, employee2.salary # employee2.reload.salary
    assert_equal 20000, employee3.salary # employee3.reload.salary
  end

  def test_only_satisfactory_employees_get_raises
    employee = Employee.create( name: "Joanna", email: "jdark@example.com", phone: "515-888-4821", salary: 80000)
    employee2 = Employee.create( name: "Lunk", email: "lunk@example.com", phone: "882-329-3843", salary: 150000)
    employee2.give_review("bad negative less")

    development = Department.create(name: "Development")
    development.add_employee(employee)
    development.add_employee(employee2)

    development.give_raise(10000)
    assert_equal 90000, employee.salary
    assert_equal 150000, employee2.salary
  end

  def test_no_raises_for_all_bad_employees
    employee = Employee.create( name: "Joanna", email: "jdark@example.com", phone: "515-888-4821", salary: 80000)
    employee.give_review("bad negative less")
    employee2 = Employee.create( name: "Lunk", email: "lunk@example.com", phone: "882-329-3843", salary: 150000)
    employee2.give_review("bad negative less")
    development = Department.create(name: "Development")
    development.add_employee(employee)
    development.add_employee(employee2)
    development.give_raise(20000)
    assert_equal 80000, employee.salary
    assert_equal 150000, employee2.salary
  end

  def test_reviews_can_be_scanned_and_classified
    employee = Employee.create( name: "Zeke", salary: 100 )
    z_review = "Zeke is a very positive person and encourages those around him, but he has not done well technically this year.  There are two areas in which Zeke has room for improvement.  First, when communicating verbally (and sometimes in writing), he has a tendency to use more words than are required.  This conversational style does put people at ease, which is valuable, but it often makes the meaning difficult to isolate, and can cause confusion.
    Second, when discussing new requirements with project managers, less of the information is retained by Zeke long-term than is expected.  This has a few negative consequences: 1) time is spent developing features that are not useful and need to be re-run, 2) bugs are introduced in the code and not caught because the tests lack the same information, and 3) clients are told that certain features are complete when they are inadequate.  This communication limitation could be the fault of project management, but given that other developers appear to retain more information, this is worth discussing further."
    employee2 = Employee.create( name: "Xavier", salary: 100 )
    x_review = "Xavier is a huge asset to SciMed and is a pleasure to work with.  He quickly knocks out tasks assigned to him, implements code that rarely needs to be revisited, and is always willing to help others despite his heavy workload.  When Xavier leaves on vacation, everyone wishes he didn't have to go
    Last year, the only concerns with Xavier performance were around ownership.  In the past twelve months, he has successfully taken full ownership of both Acme and Bricks, Inc.  Aside from some false starts with estimates on Acme, clients are happy with his work and responsiveness, which is everything that his managers could ask for."
    employee3 = Employee.create( name: "Yvonne", salary: 100 )
    y_review = "Thus far, there have been two concerns over Yvonne's performance, and both have been discussed with her in internal meetings.  First, in some cases, Yvonne takes longer to complete tasks than would normally be expected.  This most commonly manifests during development on existing applications, but can sometimes occur during development on new projects, often during tasks shared with Andrew.  In order to accommodate for these preferences, Yvonne has been putting more time into fewer projects, which has gone well.
    Second, while in conversation, Yvonne has a tendency to interrupt, talk over others, and increase her volume when in disagreement.  In client meetings, she also can dwell on potential issues even if the client or other attendees have clearly ruled the issue out, and can sometimes get off topic."
    employee4 = Employee.create( name: "Wanda", salary: 100 )
    w_review = "Wanda has been an incredibly consistent and effective developer.  Clients are always satisfied with her work, developers are impressed with her productivity, and she's more than willing to help others even when she has a substantial workload of her own.  She is a great asset to Awesome Company, and everyone enjoys working with her.  During the past year, she has largely been devoted to work with the Cement Company, and she is the perfect woman for the job.  We know that work on a single project can become monotonous, however, so over the next few months, we hope to spread some of the Cement Company work to others.  This will also allow Wanda to pair more with others and spread her effectiveness to other projects."

    employee.give_review(z_review)
    employee2.give_review(x_review)
    employee3.give_review(y_review)
    employee4.give_review(w_review)

    refute employee.satisfactory?
    assert employee2.satisfactory?
    refute employee3.satisfactory?
    assert employee4.satisfactory?
  end

#_____________________ NEW TESTS _____________________________

  def test_total_employees_in_department
    employee = Employee.create(name: "Naomi", email: "me@example.com", phone: "555-555-5555", salary: 180000)
    employee2 = Employee.create(name: "Aaron", email: "you@example.com", phone: "777-777-7777", salary: 250000)
    kindergarten = Department.create(name: "Kindergarten")
    kindergarten.add_employee(employee)
    kindergarten.add_employee(employee2)
    assert_equal 2, kindergarten.total_employees
  end

  def test_least_paid_employee
    employee = Employee.create(name: "Naomi", email: "me@example.com", phone: "555-555-5555", salary: 10)
    employee2 = Employee.create(name: "Aaron", email: "you@example.com", phone: "777-777-7777", salary: 5)
    kindergarten = Department.create(name: "Kindergarten")
    kindergarten.add_employee(employee)
    kindergarten.add_employee(employee2)
    assert_equal employee2, kindergarten.least_paid
  end

  def test_alphabetical_employees
    employee = Employee.create(name: "Sammy", email: "me@example.com", phone: "555-555-5555", salary: 16)
    employee2 = Employee.create(name: "Jola", email: "you@example.com", phone: "777-777-7777", salary: 9)
    employee3 = Employee.create(name: "Mikey", email: "you@example.com", phone: "777-777-7777", salary: 20)

    technology = Department.create(name: "Technology")
    technology.add_employee(employee)
    technology.add_employee(employee2)
    technology.add_employee(employee3)

    assert_equal [employee2, employee3, employee], technology.alphabetize_names
  end

  def test_employees_more_than_average_salary
    employee = Employee.create(name: "Sammy", email: "me@example.com", phone: "555-555-5555", salary: 16)
    employee2 = Employee.create(name: "Jola", email: "you@example.com", phone: "777-777-7777", salary: 9)
    employee3 = Employee.create(name: "Mikey", email: "you@example.com", phone: "777-777-7777", salary: 20)

    technology = Department.create(name: "Technology")
    technology.add_employee(employee)
    technology.add_employee(employee2)
    technology.add_employee(employee3)

    assert_equal [employee, employee3], technology.salary_above_average
  end

  def test_palindrome_names
    employee = Employee.create(name: "Hallah", email: "me@example.com", phone: "555-555-5555", salary: 16)
    employee2 = Employee.create(name: "Notme", email: "you@example.com", phone: "777-777-7777", salary: 9)
    employee3 = Employee.create(name: "Anderredna", email: "you@example.com", phone: "777-777-7777", salary: 20)

    technology = Department.create(name: "Technology")
    technology.add_employee(employee)
    technology.add_employee(employee2)
    technology.add_employee(employee3)

    assert_equal [employee, employee3], technology.palindrome
  end

#  Return the department with the most employees.
  def test_department_with_most_employees
    employee = Employee.create(name: "Sammy", email: "me@example.com", phone: "555-555-5555", salary: 16)
    employee2 = Employee.create(name: "Jola", email: "you@example.com", phone: "777-777-7777", salary: 9)
    employee3 = Employee.create(name: "Mikey", email: "you@example.com", phone: "777-777-7777", salary: 20)

    technology = Department.create(name: "Technology")
    technology.add_employee(employee)
    technology.add_employee(employee2)
    technology.add_employee(employee3)

    employee4 = Employee.create(name: "Naomi", email: "you@example.com", phone: "777-777-7777", salary: 20)
    employee5 = Employee.create(name: "Aaron", email: "you@example.com", phone: "777-777-7777", salary: 20)

    insurance = Department.create(name: "Insurance")
    insurance.add_employee(employee4)
    insurance.add_employee(employee5)

    assert_equal technology, Department.most_employees
  end

#   def test_moving_employees_from_one_department_to_another
#       employee = Employee.create(name: "Sammy", email: "me@example.com", phone: "555-555-5555", salary: 16)
#       employee2 = Employee.create(name: "Jola", email: "you@example.com", phone: "777-777-7777", salary: 9)
#       employee3 = Employee.create(name: "Mikey", email: "you@example.com", phone: "777-777-7777", salary: 20)
#
#       technology = Department.create(name: "Technology")
#       technology.add_employee(employee)
#       technology.add_employee(employee2)
#       technology.add_employee(employee3)
#
#       employee4 = Employee.create(name: "Naomi", email: "you@example.com", phone: "777-777-7777", salary: 20)
#       employee5 = Employee.create(name: "Aaron", email: "you@example.com", phone: "777-777-7777", salary: 20)
#
#       insurance = Department.create(name: "Insurance")
#       insurance.add_employee(employee4)
#       insurance.add_employee(employee5)
#
#     assert_equal 5, department.move_employees
# end

end
