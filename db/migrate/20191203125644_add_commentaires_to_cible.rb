class AddCommentairesToCible < ActiveRecord::Migration[6.0]
  def change
    add_column :cibles, :commentaires, :text
  end
end
