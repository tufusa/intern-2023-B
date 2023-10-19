require 'active_record/connection_adapters/sqlite3_adapter'

class ActiveRecord::ConnectionAdapters::SQLite3Adapter
  alias old_initialize initialize
  private :old_initialize

  def initialize(connection, *args)
    old_initialize(connection, *args)

    connection.create_function('REGEXP', 2) do |func, pattern, expression|
      func.result = /#{pattern}/.match?(expression.to_s) ? 1 : 0
    end
  end
end

if ENV['DB_MODE'] == 'production'
  require 'activerecord/lib/active_record/connection_adapters/postgresql_adapter'

  class ActiveRecord::ConnectionAdapters::PostgreSQLAdapter
    alias old_initialize initialize
    private :old_initialize
  
    def initialize(connection, *args)
      old_initialize(connection, *args)
  
      connection.create_function('REGEXP', 2) do |func, pattern, expression|
        func.result = /#{pattern}/.match?(expression.to_s) ? 1 : 0
      end
    end
  end
end
