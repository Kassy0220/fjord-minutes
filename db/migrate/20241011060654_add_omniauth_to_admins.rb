class AddOmniauthToAdmins < ActiveRecord::Migration[7.2]
  def change
    add_column :admins, :provider, :string, null: false
    add_column :admins, :uid, :string, null: false
    add_column :admins, :name, :string
    add_column :admins, :avatar_url, :string
  end
end
