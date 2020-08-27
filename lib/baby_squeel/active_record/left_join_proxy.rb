module BabySqueel
  module ActiveRecord
    class LeftJoinProxy
      def initialize(relation, reflection)
        @_relation = relation
        @_reflection = reflection
      end
      
      attr_reader :_relation, :_reflection
      
      def inspect
        "BabySqueel::ActiveRecord::LeftJoinProxy{#{@_relation.inspect}}"
      end
      
      def respond_to?(meth, include_private = false)
        super || @_relation.respond_to?(meth, include_private)
      end
      
      def kind_of?(t)
        super || @_relation.kind_of?(t)
      end
      
      private
      
      def method_missing(meth, *args, &block)
        if @_relation.respond_to?(meth)
          result = @_relation.send(meth, *args, &block)
          if result.kind_of?(::ActiveRecord::Relation)
            LeftJoinProxy.new(result, @_reflection)
          else
            result
          end
        else
          super
        end
      end
    end
  end
end
