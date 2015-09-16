require 'active_record'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'employee.sqlite3'
)

class Employee < ActiveRecord::Base
  belongs_to :department
  has_many :reviews

  def satisfactory?
    if self.satisfactory == nil
      self.satisfactory = true
    else
      self.satisfactory
    end
  end

  def give_raise(amount)
    #self.salary += amount
    self.update(salary: salary + amount)
  end

  def give_review(review)
    Review.create(review: review, employee_id: self.id)
    assess_performance
    true
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


  # def palindrome
  #   self.name.where("name: name.reverse").to_a
  # end



end
