class AddPoToFacture < ActiveRecord::Migration[6.0]
  def change
    add_column :factures, :po, :string
  end
end
