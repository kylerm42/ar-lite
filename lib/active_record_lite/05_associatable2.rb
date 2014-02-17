require_relative '04_associatable'

module Associatable
  def has_one_through(name, through_name, source_name)
    through_options = assoc_options[through_name]

    define_method(name) do
      source_options = through_options.model_class.assoc_options[source_name]

      query = <<-SQL
        SELECT
          y.*
        FROM
          #{through_options.table_name} x
        JOIN
          #{source_options.table_name} y
          ON x.#{source_options.foreign_key} = y.#{source_options.primary_key}
      SQL

      params = DBConnection.execute(query).first
      source_options.model_class.new(params)
    end
  end
end
