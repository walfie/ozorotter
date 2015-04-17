module ObjectFromHash
  attr_reader :fields

  def initialize(opts={})
    @fields = {}
    opts.each do |k,v|
      instance_variable_set("@#{k}", v)
      @fields[k] = v
    end
  end

  def ==(other)
    other.class == self.class && other.fields == self.fields
  end
end

