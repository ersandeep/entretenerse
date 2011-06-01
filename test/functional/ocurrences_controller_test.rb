require 'rails/test_helper'

class OcurrencesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:ocurrences)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create ocurrence" do
    assert_difference('Ocurrence.count') do
      post :create, :ocurrence => { }
    end

    assert_redirected_to ocurrence_path(assigns(:ocurrence))
  end

  test "should show ocurrence" do
    get :show, :id => ocurrences(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => ocurrences(:one).id
    assert_response :success
  end

  test "should update ocurrence" do
    put :update, :id => ocurrences(:one).id, :ocurrence => { }
    assert_redirected_to ocurrence_path(assigns(:ocurrence))
  end

  test "should destroy ocurrence" do
    assert_difference('Ocurrence.count', -1) do
      delete :destroy, :id => ocurrences(:one).id
    end

    assert_redirected_to ocurrences_path
  end
end
