# frozen_string_literal: true

require 'test_helper'

require 'generators/aws_record/scaffold_controller/scaffold_controller_generator'

module AwsRecord
  module Generators
    # @api private
    class ScaffoldControllerGeneratorTest < Rails::Generators::TestCase
      tests ScaffoldControllerGenerator
      destination File.expand_path('../../../dummy', __dir__)

      def run_generator(args, config = {})
        result = nil
        capture(:stderr) do
          result = super(args, config)
        end
        result
      end

      def test_generates_controller_skeleton_properly
        run_generator %w[ControllerSkeletonTest name age:int --skip-table-config -f]

        assert_file "app/controllers/controller_skeleton_tests_controller.rb" do |content|
          assert_match(/class ControllerSkeletonTestsController < ApplicationController/, content)

          assert_instance_method :index, content do |m|
            assert_match(/@controller_skeleton_tests = ControllerSkeletonTest\.scan/, m)
          end

          assert_instance_method :show, content

          assert_instance_method :new, content do |m|
            assert_match(/@controller_skeleton_test = ControllerSkeletonTest\.new/, m)
          end

          assert_instance_method :edit, content

          assert_instance_method :create, content do |m|
            assert_match(/@controller_skeleton_test = ControllerSkeletonTest\.new\(controller_skeleton_test_params\)/, m)
            assert_match(/@controller_skeleton_test\.save/, m)
          end

          assert_instance_method :update, content do |m|
            assert_match(/@controller_skeleton_test\.update\(controller_skeleton_test_params\)/, m)
          end

          assert_instance_method :destroy, content do |m|
            assert_match(/@controller_skeleton_test\.delete!/, m)
            assert_match(/Controller skeleton test was successfully destroyed./, m)
          end

          assert_instance_method :set_controller_skeleton_test, content do |m|
            assert_match(/@controller_skeleton_test = ControllerSkeletonTest\.find\(uuid: CGI.unescape\(params\[:id\]\)\)/, m)
          end

          assert_instance_method :controller_skeleton_test_params, content do |m|
            assert_match(/params\.require\(:controller_skeleton_test\)\.permit\(:uuid, :name, :age\)/, m)
          end
        end
      end

      def test_generates_api_controller_skeleton_properly
        run_generator %w[ApiControllerSkeletonTest --api --skip-table-config -f]

        assert_file "app/controllers/api_controller_skeleton_tests_controller.rb" do |content|
          assert_match(/class ApiControllerSkeletonTestsController < ApplicationController/, content)
          refute_match(/respond_to/, content)

          assert_match(/before_action :set_api_controller_skeleton_test, only: \[:show, :update, :destroy\]/, content)

          assert_instance_method :index, content do |m|
            assert_match(/@api_controller_skeleton_tests = ApiControllerSkeletonTest\.scan/, m)
            assert_match(/render json: @api_controller_skeleton_tests/, m)
          end

          assert_instance_method :show, content do |m|
            assert_match(/render json: @api_controller_skeleton_test/, m)
          end

          assert_instance_method :create, content do |m|
            assert_match(/@api_controller_skeleton_test = ApiControllerSkeletonTest\.new\(api_controller_skeleton_test_params\)/, m)
            assert_match(/@api_controller_skeleton_test\.save/, m)
            assert_match(/@api_controller_skeleton_test\.errors/, m)
          end

          assert_instance_method :update, content do |m|
            assert_match(/@api_controller_skeleton_test\.update\(api_controller_skeleton_test_params\)/, m)
            assert_match(/@api_controller_skeleton_test\.errors/, m)
          end

          assert_instance_method :destroy, content do |m|
            assert_match(/@api_controller_skeleton_test\.delete!/, m)
          end
        end

        assert_no_file "app/views/api_controller_skeleton_tests/index.html.erb"
        assert_no_file "app/views/api_controller_skeleton_tests/edit.html.erb"
        assert_no_file "app/views/api_controller_skeleton_tests/show.html.erb"
        assert_no_file "app/views/api_controller_skeleton_tests/new.html.erb"
        assert_no_file "app/views/api_controller_skeleton_tests/_form.html.erb"
      end

    end
  end
end
