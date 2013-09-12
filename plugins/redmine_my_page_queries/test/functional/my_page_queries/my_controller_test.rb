require File.expand_path('../../../test_helper', __FILE__)
require 'my_controller'

# Re-raise errors caught by the controller.
class MyController; def rescue_action(e) raise e end; end

class MyPageQueries::MyControllerTest < ActionController::TestCase
  fixtures :users, :user_preferences, :roles, :projects, :members, :member_roles,
  :issues, :issue_statuses, :trackers, :enumerations, :custom_fields, :auth_sources,
  :queries, :trackers, :enabled_modules

  def setup
    @controller = MyController.new
    @request    = ActionController::TestRequest.new
    @request.session[:user_id] = 2
    @response   = ActionController::TestResponse.new
    @user = User.find(2)
  end

  def test_index
    get :index
    assert_response :success
  end

  def test_page_layout
    query = Query.find(5)
    @user.pref[:my_page_layout] = { 'top' => ['query_5'] }
    @user.pref.save!
    get :page_layout
    assert_response :success
    assert_tag :h3, :content => /#{query.name}/
  end

  def test_page_layout_with_missing_query
    @user.pref[:my_page_layout] = { 'top' => ['query_66'] }
    @user.pref.save!
    get :page_layout
    assert_response :success
  end

  def test_add_block
    post :add_block, :block => 'query_5'
    assert_redirected_to '/my/page_layout'
    assert @user.pref[:my_page_layout]
    top_blocks = @user.pref[:my_page_layout]['top']
    assert top_blocks
    assert top_blocks.include?('query_5')
  end

  def test_show_query_block
    query = Query.find(5)
    @user.pref[:my_page_layout] = { 'top' => ['query_5'] }
    @user.pref.save!
    get :page
    assert_response :success
    assert_tag :h3, :content => /#{query.name}/
  end

  def test_add_block_to_default
    @user.pref[:my_page_layout] = nil
    post :add_block, :block => 'query_5'
    assert_redirected_to '/my/page_layout'
    @user = User.current
    MyController::DEFAULT_LAYOUT.each do |position, block|
      assert @user.pref[:my_page_layout][position].include?(block.first)
    end
  end

  def test_remove_block
    @user.pref[:my_page_layout] = { 'top' => ['query_5'] }
    @user.pref.save!
    post :remove_block, :block => 'query_5'
    assert_redirected_to '/my/page_layout'
    @user.pref.reload
    assert_false @user.pref[:my_page_layout].values.flatten.include?('query_5')
  end

  def test_order_blocks
    xhr :post, :order_blocks, :group => 'left', 'blocks' => ['query_5', 'calendar', 'latestnews']
    assert_response :success
    assert_equal ['query_5', 'calendar', 'latestnews'], @user.pref[:my_page_layout]['left']
  end

  def test_layout_contains_users_queries
    get :page_layout
    assert_response :success
    assert_tag :option, :attributes => { :value => 'query_4'}
  end

  def test_layout_contains_other_queries
    get :page_layout
    assert_response :success
    assert_tag :option, :attributes => { :value => 'query_5'}
    assert_tag :option, :attributes => { :value => 'query_6'}
    assert_tag :option, :attributes => { :value => 'query_9'}
  end

  def test_update_query_limit
    @user.pref[:my_page_layout] = { 'top' => ['query_5'] }
    @user.pref[:query_5] = { :limit => 20 }
    @user.pref.save!
    xhr :put, :update_query_block, :query_id => 5, :query => { :limit => 3 }
    assert_response :success
    @user.pref.reload
    assert_equal 3, @user.pref[:query_5][:limit].to_i
  end

end
