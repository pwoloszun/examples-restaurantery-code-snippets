class TablesSet < ActiveRecord::Base

  validates_presence_of :count, :capacity
  validates_numericality_of :count, :capacity, :only_integer => true
  validates_numericality_of :capacity, :greater_than => 0
  validates_numericality_of :count, :greater_than_or_equal_to => 0

  def == other
    other.is_a?(self.class) && !other.nil? && self.capacity == other.capacity && self.count == other.count
  end

  def empty?
    self.count == 0
  end

  def remove_one_table_from_set
    if self.count > 0
      self.count -= 1
    end
  end

  def total_capacity
    if self.count.nil? || self.capacity.nil?
      0
    else
      self.count * self.capacity
    end
  end

  def for? capacity
    self.capacity == capacity
  end

end
