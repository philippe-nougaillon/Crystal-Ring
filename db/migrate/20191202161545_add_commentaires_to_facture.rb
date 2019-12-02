class AddCommentairesToFacture < ActiveRecord::Migration[6.0]
  def change
    add_column :factures, :commentaires, :text
  end
end
