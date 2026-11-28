# benchmark/samples.rb

module Samples
  ROWS = 100_000
  FIELDS = {
    quoted: (1..10).map{|i| "\"v#{i}\""},
    mixed: (1..10).map{|i| i.even? ? "\"v,#{i}\"" : "v#{i}"},
    plain: (1..10).map{|i| "v#{i}"},
  }

  def self.text(kind, rows = ROWS)
    (FIELDS.fetch(kind).join(',') + "\n") * rows
  end
end
