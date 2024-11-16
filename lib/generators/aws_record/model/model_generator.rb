# frozen_string_literal: true

require 'generators/aws_record/base'

module AwsRecord
  module Generators
    class ModelGenerator < Base
      def initialize(args, *options)
        self.class.source_root File.expand_path('templates', __dir__)
        super
      end

      def create_model
        template 'model.rb', File.join('app/models', class_path, "#{file_name}.rb")
      end

      def create_table_config
        return unless options['table_config']

        template 'table_config.rb',
                 File.join('db/table_config', class_path, "#{file_name}_config.rb")
      end
    end
  end
end
