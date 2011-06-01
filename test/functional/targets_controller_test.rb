require 'rails/test_helper'

class TargetsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:targets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create target" do
    assert_difference('Target.count') do
      post :create, :target => { }
    end

    assert_redirected_to target_path(assigns(:target))
  end

  test "should show target" do
    get :show, :id => targets(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => targets(:one).id
    assert_response :success
  end

  test "should update target" do
    put :update, :id => targets(:one).id, :target => { }
    assert_redirected_to target_path(assigns(:target))
  end

  test "should destroy target" do
    assert_difference('Target.count', -1) do
      delete :destroy, :id => targets(:one).id
    end

    assert_redirected_to targets_path
  end
end
