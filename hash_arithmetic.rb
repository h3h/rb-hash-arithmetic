# = Hash Arithmetic
#
# This module adds arithmetic methods to the Hash class, including
# <tt>+</tt>, <tt>+=</tt>, <tt>-</tt> and <tt>-=</tt>. The <tt>+</tt> variants
# are simple aliases to <tt>merge</tt> and <tt>merge!</tt>, while the <tt>-</tt>
# variants implement new semantics on top of the <tt>reject</tt> method.
#
# Instead of only accepting a block, <tt>reject</tt> now alternatively accepts
# an +Array+ as its sole argument. The entries in this array can be either a
# +Regexp+, a +Symbol+ or a +String+. Each value from the array will be treated
# as a filter for removal of keys from the hash. All keys are normalized with
# <tt>to_s</tt>, so a +Symbol+ vs. +String+ distinction is unnecessary.
#
# Author::    Brad Fults  (mailto:bfults@gmail.com)
# Copyright:: Copyright (c) 2008 Brad Fults
# License::   Distributes under the same terms as Ruby
#
# == Examples
#
#  >> h = {:a => 1, :b => 2}
#  => {:a=>1, :b=>2}
#  >> h - [:a]
#  => {:b=>2}
#  >> h + {:c => 3}
#  => {:c=>3, :a=>1, :b=>2}
#  >> h
#  => {:a=>1, :b=>2}
#  >> h += {:abc => 4}
#  => {:a=>1, :abc=>4, :b=>2}
#  >> h
#  => {:a=>1, :abc=>4, :b=>2}
#  >> h - [/a/]
#  => {:b=>2}
#  >> h
#  => {:a=>1, :abc=>4, :b=>2}
#  >> h -= ['b']
#  => {:a=>1, :abc=>4}
#  >> h
#  => {:a=>1, :abc=>4}

# This module is mixed into the +Hash+ class to provide the arithmetic methods.
module HashArithmetic

  # Makes all of the necessary +alias_method+ calls when the module is mixed in.
  def self.included(base)
    base.class_eval do
      alias_method :reject_without_list_arg, :reject
      alias_method :reject, :reject_with_list_arg
      alias_method :-, :reject
      alias_method :"-=", :reject_with_list_arg!
      alias_method :+, :merge
      alias_method :"+=", :merge!
    end
  end

  # Adds additional semantics to +reject+ by accepting an optional argument.
  def reject_with_list_arg(list=nil, &block)
    if !block_given? && list && list.any?
      hash = self.dup
      list.each do |f|
        case f
        when Regexp
          hash.delete_if {|k, v| k.to_s =~ f}
        when Symbol
          hash.delete_if {|k, v| k.to_s == f.to_s}
        when String
          hash.delete_if {|k, v| k.to_s == f}
        end
      end
      return hash
    end
    return reject_without_list_arg(&block)
  end

  # Provides a destructive version of the new +reject+ method.
  def reject_with_list_arg!(list, &block)
    self = reject_with_list_arg(list, &block)
  end

end

class Hash # :nodoc:
  include HashArithmetic
end
