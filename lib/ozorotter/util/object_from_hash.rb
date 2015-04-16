module ObjectFromHash
  def initialize(opts={})
    opts.each { |k,v| instance_variable_set("@#{k}", v) }
  end
end

