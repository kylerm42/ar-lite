require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    where_line = params.keys.map { |attr_name| "#{attr_name} = ?"}.join(" AND ")

    query = <<-SQL
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL

    results = DBConnection.execute(query, *params.values)
    results.map { |attrs| self.new(attrs) }
  end
end

class SQLObject
  extend Searchable
end
