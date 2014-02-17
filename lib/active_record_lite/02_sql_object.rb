require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map do |params|
      self.new(params)
    end
  end
end

class SQLObject < MassObject
  def self.columns
    columns = DBConnection.execute2("SELECT * FROM #{self.table_name}")
                          .first
                          .map(&:to_sym)

    columns.each do |column|
      define_method(column) { self.attributes[column] }

      define_method("#{column}=") do |value|
        self.attributes[column] = value
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    @table_name ||= self.to_s.pluralize.underscore
  end

  def self.all
    query = <<-SQL
      SELECT
        *
      FROM
        #{table_name}
    SQL

    results = DBConnection.execute(query)
    self.parse_all(results)
  end

  def self.find(id)
    query = <<-SQL
      SELECT
        *
      FROM
        #{table_name}
      WHERE
        id = ?
    SQL

    self.new(DBConnection.execute(query, id).first)
  end

  def attributes
    @attributes ||= Hash.new
  end

  def attribute_values
    self.attributes.values
  end

  def initialize(params = {})
    params.each do |attr_name, value|
      unless self.class.columns.include?(attr_name.to_sym)
        raise "unknown attribute #{attr_name}"
      end

      attributes[attr_name.to_sym] = value
    end
  end

  def insert
    col_names = "(#{self.attributes.keys.join(", ")})"
    question_marks = "(#{(['?'] * self.attributes.values.length).join(', ')})"

    query = <<-SQL
      INSERT INTO
        #{self.class.table_name} #{col_names}
      VALUES
        #{question_marks}
    SQL

    DBConnection.execute(query, *attribute_values)

    self.id = DBConnection.last_insert_row_id
  end

  def update
    set_line = attributes.keys.map { |attr_name| "#{attr_name} = ?"}.join(", ")

    query = <<-SQL
      UPDATE
        #{self.class.table_name}
      SET
        #{set_line}
      WHERE
        id = ?
    SQL

    DBConnection.execute(query, *attribute_values, self.id)
  end

  def save
    self.id.nil? ? self.insert : self.update
  end
end