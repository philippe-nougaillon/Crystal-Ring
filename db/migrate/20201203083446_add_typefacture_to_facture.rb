class AddTypefactureToFacture < ActiveRecord::Migration[6.0]
  def change
    add_column :factures, :typefacture, :string
  end
end
