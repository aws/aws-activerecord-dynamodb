class ApiControllerSkeletonTestsController < ApplicationController
  before_action :set_api_controller_skeleton_test, only: [:show, :update, :destroy]

  # GET /api_controller_skeleton_tests
  def index
    # Warning: This performs a full table scan, which can be very expensive if a table has many entries.
    # It is strongly recommended to implement alternative approaches such as paginated queries.
    @api_controller_skeleton_tests = ApiControllerSkeletonTest.scan

    render json: @api_controller_skeleton_tests
  end

  # GET /api_controller_skeleton_tests/1
  def show
    render json: @api_controller_skeleton_test
  end

  # POST /api_controller_skeleton_tests
  def create
    @api_controller_skeleton_test = ApiControllerSkeletonTest.new(api_controller_skeleton_test_params)

    if @api_controller_skeleton_test.save
      render json: @api_controller_skeleton_test, status: :created, location: @api_controller_skeleton_test
    else
      render json: @api_controller_skeleton_test.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /api_controller_skeleton_tests/1
  def update
    if @api_controller_skeleton_test.update(api_controller_skeleton_test_params)
      render json: @api_controller_skeleton_test
    else
      render json: @api_controller_skeleton_test.errors, status: :unprocessable_entity
    end
  end

  # DELETE /api_controller_skeleton_tests/1
  def destroy
    @api_controller_skeleton_test.delete!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_api_controller_skeleton_test
      @api_controller_skeleton_test = ApiControllerSkeletonTest.find(uuid: CGI.unescape(params[:id]))
    end

    # Only allow a trusted parameter "white list" through.
    def api_controller_skeleton_test_params
      params.require(:api_controller_skeleton_test).permit(:uuid)
    end
end
