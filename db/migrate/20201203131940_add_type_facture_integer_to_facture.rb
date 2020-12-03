class AddTypeFactureIntegerToFacture < ActiveRecord::Migration[6.0]
  def change
    add_column :factures, :typefacture, :integer
  end
end
