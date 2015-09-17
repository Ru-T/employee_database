require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'employee.sqlite3'
)

class Employee < ActiveRecord::Base
  belongs_to :department
  has_many :reviews
  validates :salary, presence: true

  def satisfactory?
    satisfactory #.self is optional
  end

  def give_raise(amount)
    update(salary: salary + amount)
  end

  def give_review(new_review)
    Review.create(review: new_review, employee_id: self.id) #review = new_review
    assess_performance
    true
    #if review is stored in this database
    # self.review = new_review
    # assess_performance
    # save
  end

  def recent_review
    reviews.last
  end

  def assess_performance
    good_terms = [/positive/i, /good/i, /\b(en)?courag(e[sd]?|ing)\b/i, /ease/i, /improvement/i, /quick(ly)?/i, /incredibl[ey]/i, /\bimpress[edving]?{2,3}/i]
    bad_terms = [/\broom\bfor\bimprovement/i, /\boccur(ed)?\b/i, /not/i, /\bnegative\b/i, /less/i, /\bun[a-z]?{4,9}\b/i, /\b((inter)|e|(dis))?rupt[ivnge]{0,3}\b/i]
    good_terms = Regexp.union(good_terms)
    bad_terms = Regexp.union(bad_terms)

    review = self.recent_review.review

    count_good = review.scan(good_terms).length
    count_bad = review.scan(bad_terms).length

    self.satisfactory = (count_good - count_bad > 0)
  end

  def self.salary_above_average
    total = 0
    Employee.all.each do |e|
      total += e.salary
    end
    average = total / Employee.count
    Employee.where("salary > #{average}")
  end
    # WRONG: .where("employees.salary > (employees.salary.inject{|sum, salary| sum + salary }/employees.count")#employees.salary.total / employees.count
    # SQL: average = Employee.select("AVG(salary) AS average_salary").first.average_salary

    def self.palindrome
      palindrome = []
      Employee.all.each do |e|
        palindrome << e if e.name == e.name.reverse
      end
      palindrome
    end
    # OR .where(#this must be SQL) Not Ruby: (name == name.reverse).to_a

end
