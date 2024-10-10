class AddOmniauthToMembers < ActiveRecord::Migration[7.2]
  def change
    add_column :members, :provider, :string
    add_column :members, :uid, :string
    add_column :members, :name, :string
    add_column :members, :avatar_url, :string
  end
end
