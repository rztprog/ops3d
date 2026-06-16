class AddRegistrationsEnabledToOps3dSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :ops3d_settings,
            :registrations_enabled,
            :boolean,
            default: true,
            null: false
  end
end
