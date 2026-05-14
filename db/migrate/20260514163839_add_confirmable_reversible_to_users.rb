class AddConfirmableReversibleToUsers < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up do
        User.update_all(confirmed_at: Time.current)
      end
    end
  end
end
