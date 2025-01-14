# frozen_string_literal: true

require 'test_helper'

require 'fileutils'
require 'generators/aws_record/model/model_generator'

module AwsRecord
  module Generators
    # @api private
    class ModelGeneratorTest < Rails::Generators::TestCase
      tests ModelGenerator
      destination File.expand_path('../../../dummy', __dir__)

      def assert_file_fixture(fixture_file, generated_file)
        exp = File.read(fixture_file)
        act = File.read(generated_file)
        assert exp == act
      end

      def run_generator(args, config = {})
        result = nil
        capture(:stderr) do
          result = super(args, config)
        end
        result
      end

      def test_model_basic
        run_generator %w[TestModelBasic uuid:hkey --table-config=primary:5-2 -f]
        assert_file 'app/models/test_model_basic.rb'
        assert_file_fixture(
          'test/fixtures/models/test_model_basic.rb',
          'test/dummy/app/models/test_model_basic.rb'
        )
      end

      def test_model_fields_absent_auto_uuid
        run_generator %w[TestModelFieldsAbsentAutoUuid --table-config=primary:5-2 -f]
        assert_file 'app/models/test_model_fields_absent_auto_uuid.rb'
        assert_file_fixture(
          'test/fixtures/models/test_model_fields_absent_auto_uuid.rb',
          'test/dummy/app/models/test_model_fields_absent_auto_uuid.rb'
        )
      end

      def test_model_fields_present_auto_uuid
        run_generator %w[TestModelFieldsPresentAutoUuid name --table-config=primary:5-2 -f]
        assert_file 'app/models/test_model_fields_present_auto_uuid.rb'
        assert_file_fixture(
          'test/fixtures/models/test_model_fields_present_auto_uuid.rb',
          'test/dummy/app/models/test_model_fields_present_auto_uuid.rb'
        )
      end

      def test_model_auto_hkey
        run_generator %w[TestModelAutoHkey uuid --table-config=primary:5-2 -f]
        assert_file 'app/models/test_model_auto_hkey.rb'
        assert_file_fixture(
          'test/fixtures/models/test_model_auto_hkey.rb',
          'test/dummy/app/models/test_model_auto_hkey.rb'
        )
      end

      def test_model_mut_tracking
        run_generator %w[TestModelMutTracking uuid:hkey --disable-mutation-tracking --table-config=primary:5-2 -f]
        assert_file 'app/models/test_model_mut_tracking.rb'
        assert_file_fixture(
          'test/fixtures/models/test_model_mut_tracking.rb',
          'test/dummy/app/models/test_model_mut_tracking.rb'
        )
      end

      def test_model_complex
        run_generator %w[TestModelComplex forum_uuid:hkey post_id:rkey author_username post_title post_body
                         tags:sset:default_value{Set.new} created_at:datetime:db_attr_name{PostCreatedAtTime} moderation:boolean:default_value{false} --table-config=primary:5-2 -f]
        assert_file 'app/models/test_model_complex.rb'
        assert_file_fixture(
          'test/fixtures/models/test_model_complex.rb',
          'test/dummy/app/models/test_model_complex.rb'
        )
      end

      def test_enforce_uniqueness_of_field_names
        expect do
          run_generator %w[TestModel_Err uuid:hkey uuid --table-config=primary:5-2 -f]
        end.to raise_error(SystemExit)
        assert_no_file 'app/models/test_model_err.rb'
      end

      def test_enforce_uniqueness_of_db_attribute_name
        expect do
          run_generator %w[TestModel_Err uuid:hkey long_title:db_attr_name{uuid} --table-config=primary:5-2 -f]
        end.to raise_error(SystemExit)
        assert_no_file 'app/models/test_model_err.rb'
      end

      def test_enforce_errors_handled
        expect do
          run_generator %w[TestModel_Err uuid:invalid_type:hkey uuid:hkey,invalid_opt uuid:string:hkey,rkey
                           uuid:map:hkey --table-config=primary:5-2 -f]
        end.to raise_error(SystemExit)
        assert_no_file 'app/models/test_model_err.rb'
      end

      def test_model_set_table_name
        run_generator %w[TestModelSetTableName --table-config=primary:5-2 --table-name=CustomTableName -f]
        assert_file 'app/models/test_model_set_table_name.rb'
        assert_file_fixture(
          'test/fixtures/models/test_model_set_table_name.rb',
          'test/dummy/app/models/test_model_set_table_name.rb'
        )
      end

      def test_table_config_test_model1_config
        expect do
          run_generator %w[TestTableConfigTestModel1 uuid:hkey -f]
        end.to raise_error(SystemExit)
        assert_no_file 'db/table_config/test_table_config_test_model1_config.rb'
      end

      def test_table_config_test_model2_config
        run_generator %w[TestTableConfigTestModel2 --table-config=primary:20-10 -f]
        assert_file 'db/table_config/test_table_config_test_model2_config.rb'
        assert_file_fixture(
          'test/fixtures/table_config/test_table_config_test_model2_config.rb',
          'test/dummy/db/table_config/test_table_config_test_model2_config.rb'
        )
      end

      def test_model_gsi_basic
        run_generator %w[TestModelGSIBasic gsi_hkey --gsi=SecondaryIndex:hkey{gsi_hkey} --table-config=primary:5-2
                         SecondaryIndex:5-2 -f]
        assert_file 'app/models/test_model_gsi_basic.rb'
        assert_file_fixture(
          'test/fixtures/models/test_model_gsi_basic.rb',
          'test/dummy/app/models/test_model_gsi_basic.rb'
        )
      end

      def test_model_gsi_keys
        run_generator %w[TestModelGSIKeys gsi_hkey gsi_rkey --gsi=SecondaryIndex:hkey{gsi_hkey},rkey{gsi_rkey}
                         --table-config=primary:5-2 SecondaryIndex:5-2 -f]
        assert_file 'app/models/test_model_gsi_keys.rb'
        assert_file_fixture(
          'test/fixtures/models/test_model_gsi_keys.rb',
          'test/dummy/app/models/test_model_gsi_keys.rb'
        )
      end

      def test_model_gsi_mult
        run_generator %w[TestModelGSIMult gsi_hkey gsi2_hkey --gsi=SecondaryIndex:hkey{gsi_hkey}
                         SecondaryIndex2:hkey{gsi2_hkey} --table-config=primary:5-2 SecondaryIndex:5-2 SecondaryIndex2:5-2 -f]
        assert_file 'app/models/test_model_gsi_mult.rb'
        assert_file_fixture(
          'test/fixtures/models/test_model_gsi_mult.rb',
          'test/dummy/app/models/test_model_gsi_mult.rb'
        )
      end

      def test_enforce_given_hkey_is_valid
        expect do
          run_generator %w[TestModel_Err gsi_rkey --gsi=SecondaryIndex:hkey{gsi_hkey},rkey{gsi_rkey}
                           --table-config=primary:5-2 SecondaryIndex:5-2 -f]
        end.to raise_error(SystemExit)
        assert_no_file 'app/models/test_model_err.rb'
      end

      def test_enforce_given_rkey_is_valid
        expect do
          run_generator %w[TestModel_Err gsi_hkey --gsi=SecondaryIndex:hkey{gsi_hkey},rkey{gsi_rkey}
                           --table-config=primary:5-2 SecondaryIndex:5-2 -f]
        end.to raise_error(SystemExit)
        assert_no_file 'app/models/test_model_err.rb'
      end

      def test_table_config_gsi_basic_config
        expect do
          run_generator %w[TestTableConfigGSIBasic gsi_hkey --gsi=SecondaryIndex:hkey{gsi_hkey}
                           --table-config=primary:5-2 -f]
        end.to raise_error(SystemExit)
        assert_no_file 'db/table_config/test_table_config_gsi_basic_config.rb'
      end

      def test_table_config_gsi_provided_config
        run_generator %w[TestTableConfigGSIProvided gsi_hkey --gsi=SecondaryIndex:hkey{gsi_hkey}
                         --table-config=primary:5-2 SecondaryIndex:50-100 -f]
        assert_file 'db/table_config/test_table_config_gsi_provided_config.rb'
        assert_file_fixture(
          'test/fixtures/table_config/test_table_config_gsi_provided_config.rb',
          'test/dummy/db/table_config/test_table_config_gsi_provided_config.rb'
        )
      end

      def test_table_config_gsi_mult_config
        run_generator %w[TestTableConfigGSIMult gsi_hkey gsi2_hkey --gsi=SecondaryIndex:hkey{gsi_hkey}
                         SecondaryIndex2:hkey{gsi2_hkey} --table-config=primary:5-2 SecondaryIndex:10-11 SecondaryIndex2:40-20]
        assert_file 'db/table_config/test_table_config_gsi_mult_config.rb'
        assert_file_fixture(
          'test/fixtures/table_config/test_table_config_gsi_mult_config.rb',
          'test/dummy/db/table_config/test_table_config_gsi_mult_config.rb'
        )
      end

      def test_values_for_nonexistant_index
        expect do
          run_generator %w[TestModel_Err gsi_hkey --gsi=SecondaryIndex:hkey{gsi_hkey} --table-config=primary:5-2
                           SecondaryIndexes:50-100]
        end.to raise_error(SystemExit)
        assert_no_file 'app/models/test_model_err.rb'
      end

      def test_model_timestamps
        run_generator %w[TestModelTimestamps --timestamps --table_config=primary:5-2 -f]
        assert_file 'app/models/test_model_timestamps.rb'
        assert_file_fixture(
          'test/fixtures/models/test_model_timestamps.rb',
          'test/dummy/app/models/test_model_timestamps.rb'
        )
      end

      def test_required_validations
        run_generator %w[TestRequiredValidations title body --required=title body --table_config=primary:5-2 -f]
        assert_file 'app/models/test_required_validations.rb'
        assert_file_fixture(
          'test/fixtures/models/test_required_validations.rb',
          'test/dummy/app/models/test_required_validations.rb'
        )
      end

      def test_length_validations
        run_generator %w[TestLengthValidations title body --length-validations=title:5-10 body:100-250
                         --table_config=primary:5-2 -f]
        assert_file 'app/models/test_length_validations.rb'
        assert_file_fixture(
          'test/fixtures/models/test_length_validations.rb',
          'test/dummy/app/models/test_length_validations.rb'
        )
      end

      def test_validations
        run_generator %w[TestValidations title body --required=title body --length-validations=title:5-10 body:100-250
                         --table_config=primary:5-2 -f]
        assert_file 'app/models/test_validations.rb'
        assert_file_fixture(
          'test/fixtures/models/test_validations.rb',
          'test/dummy/app/models/test_validations.rb'
        )
      end

      def test_password_digest
        run_generator %w[TestPasswordDigest --table_config=primary:5-2 --password-digest]
        assert_file 'app/models/test_password_digest.rb'
        assert_file_fixture(
          'test/fixtures/models/test_password_digest.rb',
          'test/dummy/app/models/test_password_digest.rb'
        )
      end

      #       it 'allows the generation of scaffold helpers' do
      #         generate_and_assert_model "TestScaffoldHelpers", "--table_config=primary:5-2", "--scaffold"
      #       end
      #
      #       it 'allows the generation of a password digest field' do
      #         generate_and_assert_model "TestPasswordDigest", "--table_config=primary:5-2", "--password-digest"
      #       end
    end
  end
end
