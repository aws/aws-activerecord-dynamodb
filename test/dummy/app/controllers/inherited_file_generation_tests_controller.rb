class InheritedFileGenerationTestsController < ApplicationController
  before_action :set_inherited_file_generation_test, only: [:show, :edit, :update, :destroy]

  # GET /inherited_file_generation_tests
  def index
    # Warning: This performs a full table scan, which can be very expensive if a table has many entries.
    # It is strongly recommended to implement alternative approaches such as paginated queries.
    @inherited_file_generation_tests = InheritedFileGenerationTest.scan
  end

  # GET /inherited_file_generation_tests/1
  def show
  end

  # GET /inherited_file_generation_tests/new
  def new
    @inherited_file_generation_test = InheritedFileGenerationTest.new
  end

  # GET /inherited_file_generation_tests/1/edit
  def edit
  end

  # POST /inherited_file_generation_tests
  def create
    @inherited_file_generation_test = InheritedFileGenerationTest.new(inherited_file_generation_test_params)

    if @inherited_file_generation_test.save
      redirect_to @inherited_file_generation_test, notice: 'Inherited file generation test was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /inherited_file_generation_tests/1
  def update
    if @inherited_file_generation_test.update(inherited_file_generation_test_params)
      redirect_to @inherited_file_generation_test, notice: 'Inherited file generation test was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /inherited_file_generation_tests/1
  def destroy
    @inherited_file_generation_test.delete!
    redirect_to inherited_file_generation_tests_url, notice: 'Inherited file generation test was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_inherited_file_generation_test
      @inherited_file_generation_test = InheritedFileGenerationTest.find(uuid: CGI.unescape(params[:id]))
    end

    # Only allow a trusted parameter "white list" through.
    def inherited_file_generation_test_params
      params.require(:inherited_file_generation_test).permit(:uuid)
    end
end
