shared_examples_for "rails_3_oauth_model" do
  # ----------------- PLUGIN CONFIGURATION -----------------------

  let(:external_user) { create_new_external_user :twitter }

  describe "loaded plugin configuration" do

    before(:all) do
      Authentication.sorcery_adapter.delete_all
      User.sorcery_adapter.delete_all

      sorcery_reload!([:external])
      sorcery_controller_property_set(:external_providers, [:twitter])
      sorcery_model_property_set(:authentications_class, Authentication)
      sorcery_controller_external_property_set(:twitter, :key, "eYVNBjBDi33aa9GkA3w")
      sorcery_controller_external_property_set(:twitter, :secret, "XpbeSdCoaKSmQGSeokz5qcUATClRW5u08QWNfv71N8")
      sorcery_controller_external_property_set(:twitter, :callback_url, "http://blabla.com")
    end

    it "responds to 'load_from_provider'" do
      expect(User).to respond_to(:load_from_provider)
    end

    it "'load_from_provider' loads user if exists" do
      external_user
      expect(User.load_from_provider :twitter, 123).to eq external_user
    end

    it "'load_from_provider' returns nil if user doesn't exist" do
      external_user
      expect(User.load_from_provider :twitter, 980342).to be_nil
    end

  end

end
