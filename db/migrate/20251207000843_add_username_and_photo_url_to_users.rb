# frozen_string_literal: true

class AddUsernameAndPhotoUrlToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column(:users, :username, :string)
    add_column(:users, :photo_url, :string)

    # Set existing users' username to their email for now
    reversible do |dir|
      dir.up do
        User.reset_column_information
        User.find_each do |user|
          user.update_column(:username, user.email_address)
        end
      end
    end

    # Make username required
    change_column_null(:users, :username, false)
  end
end
