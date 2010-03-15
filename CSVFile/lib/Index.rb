# Index

# 20091218
# 0.4.4

# Discussion: 
# 1. Alternate names may/might have been or be: Lookup, Dictionary, Directory, and Map.  

# Changes since 0.3: 
# 1. Index#sort is now public.  
# 1/2
# 2. Index#sort! uses a default parameter rather than an instance variable to determine sort order.  
# 2/3
# 3. A small tidy.  
# 3/4
# 4. Index#sort! default sort_order now reflects the default sort_order as per the initializer.  

class Index < Array
  
  def initialize(sort_order = :insertion)
    @sort_order = sort_order
  end
  
  def []=(k,v)
    e = assoc(k)
    e ? e[1] = v : push([k,v])
    sort!
  end
  
  def [](k)
    e = assoc(k)
    e ? e[1] : nil
  end
  
  def keys
    collect{|k,v| k}
  end
  
  def values
    collect{|k,v| v}
  end
  
  def sort_order=(sort_order)
    @sort_order = sort_order
    sort!
  end
  
  def sort_order
    @sort_order
  end
  
  alias_method :std_sort!, :sort!
  def sort!(sort_order = :insertion)
    sort_order ||= @sort_order
    case sort_order
    when :insertion, :insertion_order
    when :ascending, :ascending_by_key
      std_sort!{|a,b| by_key(a, b, :ascending)}
    when :descending, :descending_by_key
      std_sort!{|a,b| by_key(a, b, :descending)}
    when :ascending_by_value
      std_sort!{|a,b| by_value(a, b, :ascending)}
    when :descending_by_value
      std_sort!{|a,b| by_value(a, b, :descending)}
    end
  end
  
  def include?(o)
    keys.include?(o)
  end
  alias_method :include_keys?, :include?
  
  def include_values?(o)
    values.include?(o)
  end
  
  private
  
  def by_key(a, b, direction)
    case direction
    when :ascending
      a[0] <=> b[0]
    when :descending
      b[0] <=> a[0]
    end
  end
  
  def by_value(a, b, direction)
    case direction
    when :ascending
      a[1] <=> b[1]
    when :descending
      b[1] <=> a[1]
    end
  end
  
end # class Index
