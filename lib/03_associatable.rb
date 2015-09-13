require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    class_name.constantize
  end

  def table_name
    class_name.underscore + "s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    @foreign_key = (name.to_s + "_id").to_sym
    @primary_key = :id
    @class_name = name.to_s.camelcase
    unless options.empty?
      options.each do |attr_name, val|
        instance_variable_set("@#{attr_name}", val)
      end
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    @foreign_key = (self_class_name.to_s.underscore + "_id").to_sym
    @primary_key = :id
    @class_name = name.to_s.singularize.camelcase
    unless options.empty?
      options.each do |attr_name, val|
        instance_variable_set("@#{attr_name}", val)
      end
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)
    assoc_options[name] = options
    define_method(name) do
      foreign_key = send(options.foreign_key)
      options.model_class.where({options.primary_key => foreign_key}).first
    end
  end

  def has_many(name, options = {})
    options = HasManyOptions.new(name, self, options)
    define_method(name) do
      primary_key = send(options.primary_key)
      options.model_class.where({options.foreign_key => primary_key})
    end
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
