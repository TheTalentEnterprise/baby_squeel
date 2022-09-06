require 'spec_helper'

describe BabySqueel::JoinDependency::Injector6_0 do
  let(:join_path) {
    BabySqueel::Join.new([])
  }

  let(:joins_values) {
    [:something, join_path, {a: :b}]
  }

  subject(:injector) { described_class.new(joins_values) }

  describe '#each' do
    it 'do not blow up without a buckets hash' do
      test_each = []
      injector.each do |join|
        test_each << join
      end
      expect(test_each).to eq(joins_values)
    end

    it 'never yields JoinPath instances to the block if buckets hash is given' do
      buckets = Hash.new { |h, k| h[k] = [] }
      injector.each do |join|
        expect(join).not_to eq(join_path)
      end
    end

    it 'adds JoinPath into buckets[:association_join]' do
      buckets = Hash.new { |h, k| h[k] = [] }
      injector.each { |join| buckets[:other] << join }
      expect(buckets[:other]).to eq([:something, { a: :b }])
      expect(buckets[:association_join]).to eq([join_path])
    end

    it 'can accompany other :association_joins' do
      buckets = Hash.new { |h, k| h[k] = [] }
      injector.each { |join| buckets[:association_join] << join }
      expect(buckets[:association_join]).to eq(joins_values)
    end
  end
end
