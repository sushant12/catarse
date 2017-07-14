# frozen_string_literal: true

module Shared
  module MaterializedView
    extend ActiveSupport::Concern

    included do
      def self.refresh_view
        connection.execute('SET statement_timeout TO 0;')
        connection.execute("REFRESH MATERIALIZED VIEW  #{table_name}")
      end
    end
  end
end
