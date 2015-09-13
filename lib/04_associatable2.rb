require_relative '03_associatable'

# Phase IV
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      results = DBConnection.execute(<<-SQL)
        SELECT
          source.*
        FROM
          #{through_options.table_name} AS through
        JOIN
          #{source_options.table_name} AS source ON
          source.#{source_options.primary_key} =
          through.#{source_options.foreign_key}
        WHERE
          through.#{through_options.primary_key} =
          #{send(through_options.foreign_key)}
      SQL
      source_options.model_class.parse_all(results).first
    end
  end

  def has_many_through(name, through_name, source_name)
    define_method(name) do
      through_options = self.class.assoc_options[through_name]
      source_options = through_options.model_class.assoc_options[source_name]
      results = DBConnection.execute(<<-SQL)
        SELECT
          source.*
        FROM
          #{through_options.table_name} AS through
        JOIN
          #{source_options.table_name} AS source ON
          source.#{source_options.primary_key} =
          through.#{source_options.foreign_key}
        WHERE
          through.#{through_options.primary_key} =
          #{send(through_options.foreign_key)}
      SQL
      source_options.model_class.parse_all(results)
    end
  end
end
