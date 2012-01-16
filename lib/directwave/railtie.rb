module DirectWave
  class Railtie < Rails::Railtie
    initializer "directwave.active_record" do
      ActiveSupport.on_load :active_record do
        require "directwave/orm/activerecord"
      end
    end
  end
end # DirectWave
