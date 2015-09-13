require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    where_line = params.map { |k, v| "#{k} = \"#{v}\""}.join(" AND ")
    all_results_hash = DBConnection.execute(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    all_results_hash.map{ |result_hash| self.new(result_hash) }
  end
end

class SQLObject
  extend Searchable
end
