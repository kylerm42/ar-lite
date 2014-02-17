require_relative '03_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :primary_key => :id,
      :foreign_key => "#{name}_id".underscore.to_sym,
      :class_name => name.to_s.camelcase.singularize
    }
    options = defaults.merge(options)

    @primary_key = options[:primary_key]
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    defaults = {
      :primary_key => :id,
      :foreign_key => "#{self_class_name}_id".underscore.to_sym,
      :class_name => name.to_s.camelcase.singularize
    }
    options = defaults.merge(options)

    @primary_key = options[:primary_key]
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
  end
end

module Associatable
  def belongs_to(name, options = {})
    association = BelongsToOptions.new(name, options)

    define_method(name) do
      relationship_id = self.send(association.foreign_key)
      association.model_class
                 .where(association.primary_key => relationship_id)
                 .first
    end

    assoc_options[name] = association
  end

  def has_many(name, options = {})
    association = HasManyOptions.new(name, self.to_s, options)

    define_method(name) do
      relationship_id = self.send(association.primary_key)
      association.model_class
                 .where(association.foreign_key => relationship_id)
    end
  end

  def assoc_options
    @params ||= Hash.new
  end
end

class SQLObject
  extend Associatable
end
