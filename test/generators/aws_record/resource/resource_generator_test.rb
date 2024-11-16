# frozen_string_literal: true

require 'test_helper'

require 'generators/aws_record/resource/resource_generator'

module AwsRecord
  module Generators
    # @api private
    class ResourceGeneratorTest < Rails::Generators::TestCase
      tests ResourceGenerator
      destination File.expand_path('../../../dummy', __dir__)

      def run_generator(args, config = {})
        result = nil
        capture(:stderr) do
          result = super(args, config)
        end
        result
      end

      def test_displays_options
        content = run_generator ['--help']
        assert_match(/--table-config=primary:R-W/, content)
      end

      def test_generates_files
        run_generator %w[InheritedFileGenerationTest --table-config=primary:5-3]

        %w[app/models/inherited_file_generation_test.rb
           db/table_config/inherited_file_generation_test_config.rb].each do |path|
          assert_file(path)
        end
      end

      def test_removes_route_on_revoke
        run_generator %w[account --table-config=primary:12-4]
        run_generator %w[account], behavior: :revoke

        assert_file 'config/routes.rb' do |route|
          refute_match(/resources :accounts$/, route)
        end
      end
    end
  end
end
