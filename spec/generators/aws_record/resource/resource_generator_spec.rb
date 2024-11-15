# frozen_string_literal: true

module AwsRecord
  module Generators

    describe ResourceGenerator do
      before(:all) do
        @gen_helper = GeneratorTestHelper.new(ResourceGenerator, "tmp")
      end
      
      after(:all) do
        @gen_helper.cleanup
      end

      it 'displays the options for inherited options' do
        content = @gen_helper.run_generator ["--help"]
        @gen_helper.assert_match(/--table-config=primary:R-W/, content)
      end

      it 'generates the files of inherited invocations' do
        @gen_helper.run_generator ["InheritedFileGenerationTest", "--table-config=primary:5-3"]
       
        %w(app/models/inherited_file_generation_test.rb db/table_config/inherited_file_generation_test_config.rb).each do |path| 
          @gen_helper.assert_file(path)
        end
      end

      it 'removes a route on revoke' do
        @gen_helper.run_generator ["account", "--table-config=primary:12-4"]
        @gen_helper.run_generator ["account"], behavior: :revoke
    
        @gen_helper.assert_file "config/routes.rb" do |route|
          @gen_helper.refute_match(/resources :accounts$/, route)
        end
      end

    end
  end
end
