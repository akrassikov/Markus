require File.join(File.dirname(__FILE__), 'authenticated_controller_test')
require File.join(File.dirname(__FILE__), '..', 'blueprints', 'helper')

class TasControllerTest < AuthenticatedControllerTest

  def setup
    clear_fixtures
  end


  context "No user" do
    should "redirect to the index" do
      get :index
      assert_redirected_to :action => "login", :controller => "main"
    end
  end # -- No user


  context "a TA" do
    setup do
      @ta = Ta.make
    end

    should "not be able to go on :index" do
      get_as @ta, :index
      assert_response :missing
    end

    should "not be able to :edit" do
      get_as @ta, :edit, :id => @ta.id
      assert_response :missing
    end

    should "not be able to :update" do
      put_as @ta, :update, :id => @ta.id
      assert_response :missing
    end

    should "not be able to :create" do
      put_as @ta, :create
      assert_response :missing
    end

  end # -- a TA


  context "An admin" do
    setup do
      @admin = Admin.make
    end

    should "be able to get :index" do
      get_as @admin, :index
      assert_response :success
    end

    should "be able to get :new" do
      get_as @admin, :new
      assert_response :success
    end

    context "with a TA" do
      setup do
        @ta = Ta.make
      end

      should "be able to edit a TA" do
        get_as @admin,
               :edit,
               :id => @ta.id
        assert_response :success
      end

      should "be able to upload a TA CSV file" do
        post_as @admin,
                :upload_ta_list,
                :userlist => fixture_file_upload('../classlist-csvs/new_students.csv')
        assert_response :redirect
        assert_redirected_to(:controller => "tas", :action => 'index')
        c8mahler = Ta.find_by_user_name('c8mahlernew')
        assert_not_nil c8mahler
        assert_generates "/en/tas/upload_ta_list", :controller => "tas", :action => "upload_ta_list"
        assert_recognizes({:controller => "tas", :action => "upload_ta_list" }, {:path => "tas/upload_ta_list", :method => :post})
      end
    end # -- With a TA
  end # -- An admin

end
