# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Sessions", type: :request) do
  let(:user) do
    User.create!(
      email_address: "test@example.com",
      username: "testuser",
      password: "TestPassword123!",
    )
  end

  describe "GET /session/new" do
    it "renders the login page" do
      get(new_session_path)
      expect(response).to(have_http_status(:success))
    end
  end

  describe "POST /session" do
    context "with valid credentials" do
      it "creates a new session and redirects to root" do
        expect do
          post(session_path, params: {
            email_address: user.email_address,
            password: "TestPassword123!",
          })
        end.to(change { Session.count }.by(1))

        expect(response).to(redirect_to(root_path))
        # Verify session was created and is associated with the user
        expect(Session.where(user: user).count).to(eq(1))
      end

      it "sets the session cookie in response headers" do
        post(session_path, params: {
          email_address: user.email_address,
          password: "TestPassword123!",
        })

        # Check that a session cookie was set
        cookies = response.headers["Set-Cookie"]
        expect(cookies).to(be_present)
        expect(cookies).to(include("session_id"))
      end

      it "redirects to return_to URL if present" do
        # First logout if already logged in
        delete(session_path) if Session.where(user: user).exists?

        # Try to access a protected page (should redirect to login)
        get("/locations/new")
        expect(response).to(redirect_to(new_session_path))
        follow_redirect!

        # Now login should redirect back to /locations/new
        post(session_path, params: {
          email_address: user.email_address,
          password: "TestPassword123!",
        })
        expect(response).to(redirect_to("/locations/new"))
      end
    end

    context "with invalid credentials" do
      it "does not create a session with incorrect email" do
        expect do
          post(session_path, params: {
            email_address: "wrong@example.com",
            password: "TestPassword123!",
          })
        end.not_to(change { Session.count })

        expect(response).to(have_http_status(:unprocessable_content))
        expect(response.body).to(include("Incorrect email or password."))
      end

      it "does not create a session with incorrect password" do
        expect do
          post(session_path, params: {
            email_address: user.email_address,
            password: "WrongPassword123!",
          })
        end.not_to(change { Session.count })

        expect(response).to(have_http_status(:unprocessable_content))
        expect(response.body).to(include("Incorrect email or password."))
      end

      it "does not create a session with empty email" do
        expect do
          post(session_path, params: {
            email_address: "",
            password: "TestPassword123!",
          })
        end.not_to(change { Session.count })

        expect(response).to(have_http_status(:unprocessable_content))
      end

      it "does not create a session with empty password" do
        expect do
          post(session_path, params: {
            email_address: user.email_address,
            password: "",
          })
        end.not_to(change { Session.count })

        expect(response).to(have_http_status(:unprocessable_content))
      end
    end
  end

  describe "DELETE /session" do
    it "destroys the session and redirects to login" do
      # First, log in
      post(session_path, params: {
        email_address: user.email_address,
        password: "TestPassword123!",
      })

      # Verify session exists
      expect(Session.where(user: user).count).to(eq(1))

      # Then, log out
      expect do
        delete(session_path)
      end.to(change { Session.count }.by(-1))

      expect(response).to(redirect_to(new_session_path))
      # Verify session was destroyed
      expect(Session.where(user: user).count).to(eq(0))
    end

    it "redirects to login even when not logged in" do
      delete(session_path)
      expect(response).to(redirect_to(new_session_path))
    end
  end
end
