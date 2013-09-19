class Array
  
  def from(index)
    self[index, length] || []
  end
  
  def to(index)
    self.first(index + 1)
  end
end