require 'rails/test_helper'

class CampaignTypesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:campaign_types)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create campaign_type" do
    assert_difference('CampaignType.count') do
      post :create, :campaign_type => { }
    end

    assert_redirected_to campaign_type_path(assigns(:campaign_type))
  end

  test "should show campaign_type" do
    get :show, :id => campaign_types(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => campaign_types(:one).id
    assert_response :success
  end

  test "should update campaign_type" do
    put :update, :id => campaign_types(:one).id, :campaign_type => { }
    assert_redirected_to campaign_type_path(assigns(:campaign_type))
  end

  test "should destroy campaign_type" do
    assert_difference('CampaignType.count', -1) do
      delete :destroy, :id => campaign_types(:one).id
    end

    assert_redirected_to campaign_types_path
  end
end
