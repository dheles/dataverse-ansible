module TestingEnvironment
  class << self
    attr_accessor :testing
  end
  self.testing = true
end
