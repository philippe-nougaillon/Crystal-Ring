class AddEnvoyeLeToCible < ActiveRecord::Migration[6.0]
  def change
    add_column :cibles, :envoyé_le, :datetime
  end
end
