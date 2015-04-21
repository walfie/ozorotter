# http://blog.rubybestpractices.com/posts/gregory/anonymous_class_hacks.html
module Ozorotter::Errors
  exceptions = %w(NotFoundError ServerError)

  exceptions.each do |e|
    const_set(e, Class.new(StandardError))
  end
end

