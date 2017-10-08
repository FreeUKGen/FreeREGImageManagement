require 'test_helper'

class ManageFreeregImagesControllerTest < ActionController::TestCase
  setup do
    @manage_freereg_image = manage_freereg_images(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:manage_freereg_images)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create manage_freereg_image" do
    assert_difference('ManageFreeregImage.count') do
      post :create, manage_freereg_image: {  }
    end

    assert_redirected_to manage_freereg_image_path(assigns(:manage_freereg_image))
  end

  test "should show manage_freereg_image" do
    get :show, id: @manage_freereg_image
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @manage_freereg_image
    assert_response :success
  end

  test "should update manage_freereg_image" do
    patch :update, id: @manage_freereg_image, manage_freereg_image: {  }
    assert_redirected_to manage_freereg_image_path(assigns(:manage_freereg_image))
  end

  test "should destroy manage_freereg_image" do
    assert_difference('ManageFreeregImage.count', -1) do
      delete :destroy, id: @manage_freereg_image
    end

    assert_redirected_to manage_freereg_images_path
  end
end
