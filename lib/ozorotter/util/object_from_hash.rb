module ObjectFromHash
  attr_reader :fields

  def initialize(opts={})
    @fields = []
    opts.each do |k,v|
      if self.respond_to?(k)
        instance_variable_set("@#{k}", v)
        @fields.push(k)
      end
    end
  end

  def ==(other)
    return false if other.class != self.class
    @fields.all? { |f| self.send(f) == other.send(f) }
  end
end

