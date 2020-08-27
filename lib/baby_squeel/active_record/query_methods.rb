require 'baby_squeel/associated_relation'
require 'baby_squeel/dsl'
require 'baby_squeel/join_dependency'
require 'baby_squeel/name_acquirer'

module BabySqueel
  module ActiveRecord
    module QueryMethods
      # Constructs Arel for ActiveRecord::QueryMethods#joins using the DSL.
      def joining(&block)
        raw_dsl_result = DSL.new(self).evaluate(&block)
        joins(Nodes.unwrap raw_dsl_result).tap do |result|
          result.joins!(Nodes.unwrap_left_joins raw_dsl_result)
        end
      end
      
      # Left-joins with a fully defined right-hand relation (to support explicit
      # join association)
      def left_joining_to(name = nil, &block)
        rhs = AssociatedRelation.evaluate_ljoin(self, name, &block)
        NameAcquirer.new(joins(rhs)).tap do |relation|
          relation.acquire_names(name => Table.new(rhs.left)) if name
        end
      end

      # Constructs Arel for ActiveRecord::QueryMethods#select using the DSL.
      def selecting(&block)
        select DSL.evaluate(self, &block)
      end

      # Constructs Arel for ActiveRecord::QueryMethods#order using the DSL.
      def ordering(&block)
        order DSL.evaluate(self, &block)
      end

      # Constructs Arel for ActiveRecord::QueryMethods#reorder using the DSL.
      def reordering(&block)
        reorder DSL.evaluate(self, &block)
      end

      # Constructs Arel for ActiveRecord::QueryMethods#group using the DSL.
      def grouping(&block)
        group DSL.evaluate(self, &block)
      end

      # Constructs Arel for ActiveRecord::QueryMethods#having using the DSL.
      def when_having(&block)
        having DSL.evaluate(self, &block)
      end

      private

      # This is a monkey patch, and I'm not happy about it.
      # Active Record will call `group_by` on the `joins`. The
      # Injector has a custom `group_by` method that handles
      # BabySqueel::Join nodes.
      if ::ActiveRecord::VERSION::MAJOR >= 5 && ::ActiveRecord::VERSION::MINOR >= 2
        def build_joins(manager, joins, aliases)
          super manager, BabySqueel::JoinDependency::Injector.new(joins), aliases
        end
      else
        def build_joins(manager, joins)
          super manager, BabySqueel::JoinDependency::Injector.new(joins)
        end
      end
    end
  end
end
