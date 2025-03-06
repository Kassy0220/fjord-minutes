class CreateGithubCredentials < ActiveRecord::Migration[7.2]
  def change
    create_table :github_credentials do |t|
      t.string :access_token, null: false
      t.string :refresh_token, null: false
      t.datetime :expires_at, null: false
      t.references :admin, null: false, foreign_key: true

      t.timestamps
    end
  end
end
