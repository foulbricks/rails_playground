class Array
  alias :prepend :unshift
  alias :append :<<
  
  # array[index, count]. Could be length - 1, but anything over last index is the same
  def from(index)
    self[index, length] || []
  end
  
  def to(index)
    self.first(index + 1)
  end
  
  def extract_options!
    self.last.is_a?(Hash) ? pop : {}
  end
  
  #[1, 2, 3, 4, 5].in_groups_of(3) =#> [[1, 2, 3], [4, 5, nil]]
  # 5 % 3 => 2, 3 -2 => 1
  # 6 % 3 => 0, 3 - 0 => 3, 3 % 3 = 0
  def in_groups_of(number, fill_with = nil)
    if fill_with == false
      collection = self
    else
      padding = ( number - size % number) % number
      collection = self.dup.concat([fill_with] * padding)
    end
    
    if block_given?
      collection.each_slice(number){|group| yield(group) }
    else
      groups = []
      collection.each_slice(number){|group| groups << group }
      groups
    end
  end
  
  #[1, 2, 3, 4].in_groups(3) =#> [[1, 2], [3, nil], [4, nil]]
  # 4 / 3 = 1, 4 % 3 = 1
  # items per array = 2; if modulo > 0 add 1 to division
  def in_groups(number, fill_with = nil)
    division = size / number
    modulo = size % number
    groups, start = [], 0
    
    number.times do |index|
      length = division - (modulo > 0 && modulo > index ? 1 : 0)
      padding = fill_with != false && modulo > 0 && length == division ? 1 : 0
      groups << self.slice(start, length).concat([fill_with] * padding)
      start += length
    end
    
    if block_given?
      groups.each{|group| yield group }
    else
      groups
    end
  end
  
  #[1, 2, 3, 4].split(3) => [[1, 2], [4]]
  def split(value = nil)
    with_block = block_given?
    
    inject([[]]) do |results, element|
      if (with_block && yield(value)) || (value == element)
        results << []
      else
        results.last << element
      end
      results
    end
  end
  
  # get random num, switch array elements, cut selection size by moving index, trim final array 
  def sample(n = nil)
    return self[Kernel.rand(size)] if n.nil?
    n = n.to_i
  rescue Exception => e
    raise TypeError, "Cannot convert to Integer"
  else
    raise(ArgumentError, "Cannot be negative number") if n < 0
    n = size if n > size
    results = Array.new(self)
    n.times do |i|
      r = i + Kernel.rand(size - i)
      results[i], results[r] = results[r], results[i]
    end
    results[n..size] = []
    results
  end unless method_defined? :sample
  
  # whatever is yielded by block becomes a hash key whose value is returned if key already present
  # if not key defined, push element into results array
  def uniq_by
    hash, results = {}, []
    self.each {|element| hash[yield(element)] ||= (results << element) }
    results
  end
  
  
  def uniq_by!
    replace(uniq_by { |element| yield element})
  end
  
  def self.wrap(object)
    if object.nil?
      return []
    elsif object.respond_to?(:to_ary)
      return object.to_ary
    else
      [object]
    end
  end
end