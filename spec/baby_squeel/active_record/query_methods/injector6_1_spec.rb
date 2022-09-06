require 'spec_helper'

describe BabySqueel::ActiveRecord::QueryMethods::Injector6_1 do
  let(:join_path) {
    BabySqueel::Join.new([])
  }

  let(:joins_values) {
    [:something, join_path, {a: :b}]
  }

  subject(:injector) { Array.new(joins_values).extend(described_class) }

  describe '#each' do
    it 'do not blow up without a result' do
      test_each = []
      injector.each do |join|
        test_each << join
      end
      expect(test_each).to eq([:something, {a: :b}])
    end

    it 'adds join_path into result' do
      result = []
      other = []
      injector.each { |join| other << join }
      expect(other).to eq([:something, { a: :b }])
      expect(result).to eq([join_path])
    end

    it 'can accompany other result' do
      result = []
      injector.each { |join| result << join }
      expect(result).to eq(joins_values)
    end
  end
end
