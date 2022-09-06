require_relative 'matchers/snapshot'
require_relative 'matchers/sql_formatter'
require_relative 'matchers/match_formatted'
require_relative 'matchers/match_snapshot'

module Matchers
  def self.version(value)
  end

  def self.suffix(variants: [])
    variant = variants.find do |variant|
      ActiveRecord::VERSION::STRING.start_with?(variant)
    end

    "(Active Record: v#{variant})" if variant
  end

  def snapshot_index(key)
    @snapshot_indexes ||= Hash.new { |h, k| h[k] = 0 }
    @snapshot_indexes[key] += 1
  end

  def match_sql_snapshot(**opts)
    example = RSpec.current_example

    snapshot = Snapshot.new(
      example.metadata,
      snapshot_index(example.id),
      suffix: Matchers.suffix(**opts)
    )

    MatchSnapshot.new(snapshot, SQLFormatter)
  end

  def produce_sql(sql)
    MatchFormatted.new(sql, SQLFormatter)
  end
end

RSpec.configure do |config|
  config.include Matchers
end
