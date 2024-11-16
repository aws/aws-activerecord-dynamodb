class ControllerSkeletonTestsController < ApplicationController
  before_action :set_controller_skeleton_test, only: [:show, :edit, :update, :destroy]

  # GET /controller_skeleton_tests
  def index
    # Warning: This performs a full table scan, which can be very expensive if a table has many entries.
    # It is strongly recommended to implement alternative approaches such as paginated queries.
    @controller_skeleton_tests = ControllerSkeletonTest.scan
  end

  # GET /controller_skeleton_tests/1
  def show
  end

  # GET /controller_skeleton_tests/new
  def new
    @controller_skeleton_test = ControllerSkeletonTest.new
  end

  # GET /controller_skeleton_tests/1/edit
  def edit
  end

  # POST /controller_skeleton_tests
  def create
    @controller_skeleton_test = ControllerSkeletonTest.new(controller_skeleton_test_params)

    if @controller_skeleton_test.save
      redirect_to @controller_skeleton_test, notice: 'Controller skeleton test was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /controller_skeleton_tests/1
  def update
    if @controller_skeleton_test.update(controller_skeleton_test_params)
      redirect_to @controller_skeleton_test, notice: 'Controller skeleton test was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /controller_skeleton_tests/1
  def destroy
    @controller_skeleton_test.delete!
    redirect_to controller_skeleton_tests_url, notice: 'Controller skeleton test was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_controller_skeleton_test
      @controller_skeleton_test = ControllerSkeletonTest.find(uuid: CGI.unescape(params[:id]))
    end

    # Only allow a trusted parameter "white list" through.
    def controller_skeleton_test_params
      params.require(:controller_skeleton_test).permit(:uuid, :name, :age)
    end
end
