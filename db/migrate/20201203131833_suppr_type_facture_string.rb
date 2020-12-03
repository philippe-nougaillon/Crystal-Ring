class SupprTypeFactureString < ActiveRecord::Migration[6.0]
  def change
    remove_column :factures, :typefacture

  end
end
