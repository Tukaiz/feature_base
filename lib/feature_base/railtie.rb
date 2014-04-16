module FeatureBase
  class Railtie < Rails::Railtie
    initializer "my_railtie.configure_rails_initialization" do |app|
      app.config.tkml_features = []
    end
  end
end
