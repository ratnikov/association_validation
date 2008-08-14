module Generators
  module_function

  def make_validator association_id, validation_method_name
    Module.new do
      define_method validation_method_name do
        association = send(association_id)
        unless association.blank?
          unless association.valid?
            association.errors.each_full { |msg| errors.add(association_id, "is invalid: #{msg}") }
          end
        else
          # presence validation should be done separately
        end
      end
    end
  end
end

ActiveRecord::Associations::ClassMethods.module_eval do
  def has_one_with_validation(association_id, options = {}, &extension)
    validate = options.has_key?(:validate) ? options.delete(:validate) : false
    ret_val = has_one_without_validation(association_id, options, &extension)
    if validate
      include Generators::make_validator(association_id, "validate_#{association_id}")
      validate "validate_#{association_id}".to_sym
    end
    ret_val
  end
  alias_method_chain :has_one, :validation

end
