# frozen_string_literal: true

require 'aws-record'

module ModelTableConfig
  def self.config
    Aws::Record::TableConfig.define do |t|
      t.model_class Account

      t.read_capacity_units 12
      t.write_capacity_units 4
    end
  end
end
