# Array.rb

# 2010.05.03
# 0.8.2

# Changes: 
# 1. Removed unused code: #each_with_index and #collect_with_index, upon which it relies.  

class Array
  
  def to_csv(quote = :double)
    pp self if $debug[:Array_to_csv]
    case quote.to_sym # Also handles 'double', 'double_qoute', ...
      when :double, :double_quote, :double_quotes, :double_quoted, :doubly_quoted
        return quote_each('"').join(',')
      when :strict_double, :strict_double_quote, :strict_double_quotes, :strict_double_quoted, :strict_doubly_quoted
        return quote_each('"').join(',')
      when :spacey_double, :spacey_double_quote, :spacey_double_quotes, :spacey_double_quoted, :spacey_doubly_quoted
        return quote_each('"').join(', ')
      when :single, :single_quote, :single_quotes, :single_quoted, :singly_quoted
        return quote_each("'").join(',')
      when :strict_single, :strict_single_quote, :strict_single_quotes, :strict_single_quoted, :strict_singly_quoted
        return quote_each("'").join(',')
      when :spacey_single, :spacey_single_quote, :spacey_single_quotes, :spacey_single_quoted, :spacey_singly_quoted
        return quote_each("'").join(', ')
      when :none, :no_quotes, :not_quoted, :unquoted
        return join(',')
      when :strict_none, :strict_no_quotes, :strict_not_quoted, :strict_unquoted
        return join(',')
      when :spacey_none, :spacey_no_quotes, :spacey_not_quoted, :spacey_unquoted
        return join(', ')
    end # case
  end # def to_csv
  
  def wrap_each(wrapper)
    collect{|e| e.wrap(wrapper)}
  end
  alias_method :wrap_each_with, :wrap_each
  alias_method :wrap_each_with___, :wrap_each
  
  def wrap_each!(wrapper)
    collect!{|e| e.wrap(wrapper)}
  end
  alias_method :wrap_each_with!, :wrap_each!
  alias_method :wrap_each_with___!, :wrap_each!
  
  def unwrap_each(wrapper)
    collect{|e| e.unwrap(wrapper)}
  end
  alias_method :unwrap_each_of, :unwrap_each
  alias_method :unwrap_each_of___, :unwrap_each
  
  def unwrap_each!(wrapper)
    collect!{|e| e.unwrap(wrapper)}
  end
  alias_method :unwrap_each_of!, :unwrap_each!
  alias_method :unwrap_each_of___!, :unwrap_each!
  
  def quote_each(mark = '"')
    wrap_each(mark)
  end
  
  def quote_each!(mark = '"')
    wrap_each!(mark)
  end
  
  def unquote_each(mark = '"')
    unwrap_each(mark)
  end
  
  def unquote_each!(mark = '"')
    unwrap_each!(mark)
  end
  
end # class Array
