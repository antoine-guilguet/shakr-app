require "test_helper"

class VoiceControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
  end

  test "show returns success" do
    get voice_path
    assert_response :success
    assert_match(/data-realtime-voice-autostart-value="false"/, response.body)
  end

  test "show with autostart sets autostart data attribute" do
    get voice_path(autostart: 1)
    assert_response :success
    assert_match(/data-realtime-voice-autostart-value="true"/, response.body)
  end

  test "show requires authentication" do
    sign_out @user
    get voice_path
    assert_redirected_to new_user_session_path
  end
end
