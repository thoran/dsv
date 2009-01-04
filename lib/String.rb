# String.rb

# 20090104, 05
# 0.6.1

# Changes: 
# 1. Moved from same file as CSVFile.  

class String
  
  def csv_split(quote = nil)
    unless quote # then auto-parse...  
      quote = :double
      double = self.match(/",|,\s*"/)
      unless double
        quote = :single
        single = self.match(/',|,\s*'/) # Singly quoted CSV files are essentially unheard of, but who knows?  
        unless single
          quote = :none
          none = self.match(/,/)
          unless none
            raise RuntimeError, "This file doesn't have any commas in it.  Are you sure that this is a CSV file?"
          end # unless none
        end # unless single
      end # unless double
    end # unless quote
    pp quote if $debug[:String_csv_split]
    result = ''
    result = case quote.to_sym # Also handles 'double', 'double_quote', ...
      when :double, :double_quote, :double_quotes, :double_quoted, :doubly_quoted # No spaces, but no integrity checks.  
        result = self.gsub(/,/, ',""').gsub(/"""/, '"') # This too is ugly, but at least it might be faster!  
        result = result.chomp.split(/",\s*"/)
        #result = self.chomp.split(/",\s*"/) # For use when temporarily commenting out the above loop.  
        result[0].sub!(/^"/, '')
        result[result.size - 1].sub!(/"$|",$/, '')
        result
      when :strict_double, :strict_double_quote, :strict_double_quotes, :strict_double_quoted, :strict_doubly_quoted
      when :spacey_double, :spacey_double_quote, :spacey_double_quotes, :spacey_double_quoted, :spacey_doubly_quoted
      when :single, :single_quote, :single_quotes, :single_quoted, :singly_quoted
        # More ugliness ensues...
        old_result = self
        loop do
          result = old_result.gsub(/,,/, ",'',")
          break if result == old_result
          old_result = result
        end
        result = self.gsub(/,,/, ",'',")
        result = result.chomp.split(/',\s*'/)
        result[0] = result[0].sub(/^'/, '')
        result[result.size - 1] = result[result.size - 1].sub(/'$/, '').sub(/',$/, '') # This last sub is also far more of a hack than most of the stuff here...  
      when :strict_single, :strict_single_quote, :strict_single_quotes, :strict_single_quoted, :strict_singly_quoted
      when :spacey_single, :spacey_single_quote, :spacey_single_quotes, :spacey_single_quoted, :spacey_singly_quoted
      when :none, :no_quotes, :not_quoted, :unquoted
        self.chomp.split(/,\s*/)
      when :strict_none, :strict_no_quote, :strict_not_quoted, :strict_unquoted
        self.chomp.split(/,/)
      when :spacey_none, :spacey_no_quote, :spacey_not_quoted, :spacey_unquoted
        self.chomp.split(/,\s+/)
      when :mixed
        result = ''
        comma_found = false
        quote_found = false
        self.each_char do |c|
          case c
          when /,/
            if comma_found == true
              result << '""'
            end
            result << c
            quote_found = false
            comma_found = true
          when /"/
          	if quote_found == true
          	  result << c
      		end
      		result << c
      		quote_found = true
      		comma_found = false
          else
          	if !(quote_found && comma_found)
              result << c
            end
            quote_found = false
            comma_found = false
          end # case c
        end # self.each_char
        #pp result; exit
        a = result.csv_split(:strict_none)
        i = -1
        new_a = []
        loop do
          #pp i, a.size
          e = a[i += 1]
          pp i
          pp a[i]
          quotes_opened = true if e.opening_quote?
          if quotes_opened
            if e.opening_quote?
              j = i - 1
              new_a[i] = ''
              pp 'e...', e
              #until e.closing_quotes?
                #pp i, j
                #pp a[i], a[j]
                #pp new_a[i], a[j + 1]
                new_a[i] = new_a[i] + ',' + a[j += 1]
              #end # until
            elsif e.closing_quote? # closing
              new_a[i] = new_a[i] + ',' + a[j += 1]
              quotes_opened = false
            else
              new_a[i] = new_a[i] + ',' + a[j += 1]
            end # if e.opening_quote?
            i = j
          elsif e.neither_opening_nor_closing_quotes?
            new_a << e.quote
          end # if e.open_xor_closing_quote?
          pp new_a
          pp i, a.size
          break if i >= a.size
        end # loop
        result = new_a
    end # case quote
    result
  end # def csv_split
  alias_method :split_csv, :csv_split
  
  # Does strictness automatically denote that integrity checks like column count equivalance is enforced?  I suggest so, since I doubt that anyone would want to strictly enforce quoting and not column count.  At some later stage I *may* allow this, but it is a really low priority.  
  
  def wrap(wrapper)
    wrapper + self + wrapper
  end
  
  def unwrap(wrapper)
    sub(/^#{wrapper}/, '').sub(/#{wrapper}$/, '')
  end
  
  def quote(mark = '"')
    wrap(mark)
  end
  
  def unquote(mark = '"')
    unwrap(mark)
  end
  
  def wrap!(wrapper)
    sub!(/^/, wrapper).sub!(/$/, wrapper) # It was only way I could think to do things in place.  Should I change #wrap to match now?  
  end
  
  def unwrap!(wrapper)
    sub!(/^#{wrapper}/, '').sub!(/#{wrapper}$/, '')
  end
  
  def quote!(mark = '"')
    wrap!(mark)
  end
  
  def unquote!(mark = '"')
    unwrap!(mark)
  end
  
  def each_char
    (0..(self.size - 1)).each{|i| yield self[i, 1]}
  end
  
  def opening_quote?
    (self =~ /^"/) ? true : false
  end
  alias_method :opening_quotes?, :opening_quote?
  
  def closing_quote?
    (self =~ /"$/) ? true : false
  end
  alias_method :closing_quotes?, :closing_quote?
  
  def opening_and_closing_quotes?
    opening_quote? && closing_quote?
  end
  
  def opening_or_closing_quotes?
    opening_quote? || closing_quote?
  end
  
  def opening_xor_closing_quotes?
    (opening_quote? || closing_quote?) && !opening_and_closing_quotes?
  end
  
  def neither_opening_nor_closing_quotes?
    !opening_and_closing_quotes?
  end
  
end # class String
