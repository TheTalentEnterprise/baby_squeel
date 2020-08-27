require 'baby_squeel/dsl'
require 'baby_squeel/active_record/left_join_proxy'

module BabySqueel
  class AssociatedRelation < DSL
    AssociatedJoin = Struct.new(:reflection, :arel_relation, :join_key, :base_column_name) do
      def reflected_arel_base
        reflection.active_record.arel_table
      end
    end
    
    class << self
      ##
      # Returns an AssociatedJoin
      #
      def evaluate_ljoin_target(scope, name, &block)
        dsl = new(scope)
        ljoin_target = dsl.evaluate(&block)
        unless ljoin_target.kind_of?(ActiveRecord::LeftJoinProxy)
          desc_scope_class = scope.respond_to?(:klass) ? scope.klass : scope.class
          raise "Can only #left_joining_to a block returning a relationship from #{desc_scope_class}, got a #{ljoin_target.class}"
        end
        relation = ljoin_target._relation
        if relation.kind_of?(Class) && relation < ::ActiveRecord::Base
          relation = relation.all
        end
        unless relation.kind_of?(::ActiveRecord::Relation)
          raise "ActiveRecord::Relation required (got #{relation.class})"
        end
        r = ljoin_target._reflection
        jk = r.get_join_keys(r.active_record)
        name ||= "#{r.name}_ljoin"
        if r.through_reflection?
          r_t = r.through_reflection
          jk_t = r_t.get_join_keys(r.active_record)
          aliased_rel = relation.arel.as(name.to_s)
          join_key_column = r_t.klass.arel_table[jk_t.key]
          base_column_name = jk_t.foreign_key
        else
          aliased_rel = relation.arel.as(name.to_s)
          join_key_column = r.klass.arel_table[jk.key]
          base_column_name = jk.foreign_key
        end
        lj_key_name = 'leftjoin_key'
        if aliased_rel.left.expr.cores.length != 1
          raise "Unexpected change to Arel::Nodes::SelectStatemet (#cores)"
        end
        aliased_rel.left.expr.cores[0].projections << join_key_column.as(lj_key_name)
        AssociatedJoin.new(r, aliased_rel, lj_key_name, base_column_name)
      end
      
      def evaluate_ljoin(scope, name, &block)
        target = evaluate_ljoin_target(scope, name, &block)
        aliased_rel = target.arel_relation
        lj_key_name = target.join_key
        foreign_key_column = target.reflected_arel_base[target.base_column_name]
        Arel::Nodes::OuterJoin.new(
          aliased_rel,
          Arel::Nodes::On.new(
            aliased_rel[lj_key_name].eq(foreign_key_column)
          )
        )
      end
      
      def make_left_joins_arel(arel_table, ljoin_targets)
        ljoin_targets.map do |target|
          aliased_rel = target.arel_relation
          lj_key_name = target.join_key
          foreign_key_column = arel_table[target.base_column_name]
          Arel::Nodes::OuterJoin.new(
            aliased_rel,
            Arel::Nodes::On.new(
              aliased_rel[lj_key_name].eq(foreign_key_column)
            )
          )
        end
      end
    end
    
    private
    def resolver
      @resolver ||= Resolver.new(self, [:associated_model])
    end
  end
end
