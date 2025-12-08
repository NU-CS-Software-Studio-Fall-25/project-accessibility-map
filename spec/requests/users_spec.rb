# frozen_string_literal: true

require "rails_helper"

RSpec.describe("Users", type: :request) do
  describe "GET /users/new" do
    it "renders the signup page" do
      get(new_user_path)
      expect(response).to(have_http_status(:success))
    end
  end

  describe "POST /users" do
    context "with valid parameters" do
      it "creates a new user and redirects to login page" do
        expect do
          post(users_path, params: {
            user: {
              username: "newuser",
              email_address: "newuser@example.com",
              password: "TestPassword123!",
              password_confirmation: "TestPassword123!",
            },
          })
        end.to(change { User.count }.by(1))

        expect(response).to(redirect_to(new_session_path))
        expect(flash[:notice]).to(eq("Account created successfully! Please sign in."))
      end

      it "normalizes email address to lowercase" do
        post(users_path, params: {
          user: {
            username: "newuser",
            email_address: "NEWUSER@EXAMPLE.COM",
            password: "TestPassword123!",
            password_confirmation: "TestPassword123!",
          },
        })

        user = User.find_by(username: "newuser")
        expect(user.email_address).to(eq("newuser@example.com"))
      end

      it "strips whitespace from email address" do
        post(users_path, params: {
          user: {
            username: "newuser",
            email_address: "  newuser@example.com  ",
            password: "TestPassword123!",
            password_confirmation: "TestPassword123!",
          },
        })

        user = User.find_by(username: "newuser")
        expect(user.email_address).to(eq("newuser@example.com"))
      end
    end

    context "with invalid parameters" do
      it "does not create user with missing username" do
        expect do
          post(users_path, params: {
            user: {
              email_address: "newuser@example.com",
              password: "TestPassword123!",
              password_confirmation: "TestPassword123!",
            },
          })
        end.not_to(change { User.count })

        expect(response).to(have_http_status(:unprocessable_content))
        expect(response.body).to(include("Username"))
      end

      it "does not create user with missing email" do
        expect do
          post(users_path, params: {
            user: {
              username: "newuser",
              password: "TestPassword123!",
              password_confirmation: "TestPassword123!",
            },
          })
        end.not_to(change { User.count })

        expect(response).to(have_http_status(:unprocessable_content))
      end

      it "does not create user with missing password" do
        expect do
          post(users_path, params: {
            user: {
              username: "newuser",
              email_address: "newuser@example.com",
              password_confirmation: "TestPassword123!",
            },
          })
        end.not_to(change { User.count })

        expect(response).to(have_http_status(:unprocessable_content))
      end

      it "does not create user with password too short" do
        expect do
          post(users_path, params: {
            user: {
              username: "newuser",
              email_address: "newuser@example.com",
              password: "Short1!",
              password_confirmation: "Short1!",
            },
          })
        end.not_to(change { User.count })

        expect(response).to(have_http_status(:unprocessable_content))
        expect(response.body).to(include("must be at least 12 characters long"))
      end

      it "does not create user with password missing complexity requirements" do
        expect do
          post(users_path, params: {
            user: {
              username: "newuser",
              email_address: "newuser@example.com",
              password: "alllowercase123",
              password_confirmation: "alllowercase123",
            },
          })
        end.not_to(change { User.count })

        expect(response).to(have_http_status(:unprocessable_content))
        expect(response.body).to(include("must include at least one lowercase letter, one uppercase letter, one digit, and one special character"))
      end

      it "does not create user with password confirmation mismatch" do
        expect do
          post(users_path, params: {
            user: {
              username: "newuser",
              email_address: "newuser@example.com",
              password: "TestPassword123!",
              password_confirmation: "DifferentPass123!",
            },
          })
        end.not_to(change { User.count })

        expect(response).to(have_http_status(:unprocessable_content))
        # Check for HTML-encoded version (doesn&#39;t) or plain version
        expect(response.body).to(match(/doesn.*t match Password/i))
      end

      it "does not create user with duplicate email" do
        User.create!(
          username: "existinguser",
          email_address: "existing@example.com",
          password: "TestPassword123!",
        )

        expect do
          post(users_path, params: {
            user: {
              username: "newuser",
              email_address: "existing@example.com",
              password: "TestPassword123!",
              password_confirmation: "TestPassword123!",
            },
          })
        end.not_to(change { User.count })

        expect(response).to(have_http_status(:unprocessable_content))
        expect(response.body).to(include("has already been taken"))
      end

      it "does not create user with duplicate email (case-insensitive)" do
        User.create!(
          username: "existinguser",
          email_address: "existing@example.com",
          password: "TestPassword123!",
        )

        expect do
          post(users_path, params: {
            user: {
              username: "newuser",
              email_address: "EXISTING@EXAMPLE.COM",
              password: "TestPassword123!",
              password_confirmation: "TestPassword123!",
            },
          })
        end.not_to(change { User.count })

        expect(response).to(have_http_status(:unprocessable_content))
      end

      it "does not create user with inappropriate username" do
        expect do
          post(users_path, params: {
            user: {
              username: "shit",
              email_address: "newuser@example.com",
              password: "TestPassword123!",
              password_confirmation: "TestPassword123!",
            },
          })
        end.not_to(change { User.count })

        expect(response).to(have_http_status(:unprocessable_content))
        expect(response.body).to(include("inappropriate"))
      end

      it "does not create user with inappropriate email" do
        expect do
          post(users_path, params: {
            user: {
              username: "newuser",
              email_address: "shit@example.com",
              password: "TestPassword123!",
              password_confirmation: "TestPassword123!",
            },
          })
        end.not_to(change { User.count })

        expect(response).to(have_http_status(:unprocessable_content))
        expect(response.body).to(include("inappropriate"))
      end
    end

    context "when user exists with OAuth provider" do
      it "redirects to login page with alert message" do
        User.create!(
          username: "oauthuser",
          email_address: "oauth@example.com",
          password: "TestPassword123!",
          provider: "google",
          uid: "123456789",
        )

        expect do
          post(users_path, params: {
            user: {
              username: "newuser",
              email_address: "oauth@example.com",
              password: "TestPassword123!",
              password_confirmation: "TestPassword123!",
            },
          })
        end.not_to(change { User.count })

        expect(response).to(redirect_to(new_session_path))
        expect(flash[:alert]).to(eq("An account with this email already exists. Please sign in with Google instead."))
      end
    end
  end

  describe "GET /users/:id" do
    let(:user) do
      User.create!(
        email_address: "test@example.com",
        username: "testuser",
        password: "TestPassword123!",
      )
    end

    it "renders the user show page" do
      get(user_path(user))
      expect(response).to(have_http_status(:success))
    end
  end
end
