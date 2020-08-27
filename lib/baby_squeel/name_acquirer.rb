module BabySqueel
  class NameAcquirer
    module Adjunct
      INSTANCE_VARIABLE = :@_acquired_names
    end
    
    def initialize(relation)
      @_relation = relation
      @_names = {}
      
      @_relation.extend Adjunct
      @_relation.instance_variable_set(Adjunct::INSTANCE_VARIABLE, @_names)
    end
    
    def inspect
      "BabySqueel::NameAcquirer{#{@_relation.inspect}}"
    end
    
    def respond_to?(meth, include_private = false)
      super || @_relation.respond_to?(meth, include_private)
    end
    
    def kind_of?(t)
      super || @_relation.kind_of?(t)
    end
    
    def acquire_names(name_hash)
      @_names.update(name_hash)
    end
    
    def acquired_names
      @_names
    end
    
    def self.names(obj)
      case obj
      when NameAcquirer
        obj.acquired_names
      when Adjunct
        obj.instance_variable_get(Adjunct::INSTANCE_VARIABLE) || {}
      else
        {}
      end
    end
    
    private
    
    def method_missing(meth, *args, &block)
      if @_relation.respond_to?(meth)
        result = @_relation.send(meth, *args, &block)
        if result.kind_of?(::ActiveRecord::Relation)
          NameAcquirer.new(result).tap do |na_result|
            na_result.acquire_names(acquired_names)
          end
        else
          result
        end
      else
        super
      end
    end
  end
end
