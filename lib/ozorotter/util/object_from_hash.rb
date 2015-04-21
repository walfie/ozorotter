module ObjectFromHash
  attr_reader :fields

  def initialize(opts={})
    @fields = {}
    opts.each do |k,v|
      if self.respond_to?(k)
        instance_variable_set("@#{k}", v)
        @fields[k] = v
      end
    end
  end

  def ==(other)
    other.class == self.class && other.fields == self.fields
  end
end

