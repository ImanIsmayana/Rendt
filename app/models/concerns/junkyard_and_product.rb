module JunkyardAndProduct
  def increment_favourites_counter
    self.favourites_count += 1
    self.save
  end

  def decrement_favourites_counter
    self.favourites_count -= 1
    self.save
  end
end