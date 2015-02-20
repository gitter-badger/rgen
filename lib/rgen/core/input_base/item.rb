module RGen::InputBase
  class Item < RGen::Base::Item
    extend Forwardable

    def self.define_field(field_name, args = {}, &body)
      return if fields.include?(field_name)

      body  ||= lambda do
        if instance_variable_defined?(field_name.variablize)
          instance_variable_get(field_name.variablize)
        else
          args[:default]
        end
      end

      define_method(field_name, body)
      fields  << field_name
    end

    def self.fields
      @fields ||= []
    end

    def self.build(&body)
      @builder  ||= body
    end

    def self.validate(&body)
      @validator  ||= body
    end

    def_class_delegator :fields
    attr_class_reader   :builder
    attr_class_reader   :validator

    def build(*sources)
      instance_exec(*sources, &builder) if builder
    end

    def validate
      instance_exec(&validator) if validator
    end
  end
end