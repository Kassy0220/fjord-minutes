class AddDefaultToReleaseBranchAndReleaseNoteInMinutes < ActiveRecord::Migration[7.2]
  def change
    change_column_default(:minutes, :release_branch, '')
    change_column_default(:minutes, :release_note, '')
  end
end
