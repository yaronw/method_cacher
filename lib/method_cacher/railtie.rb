module MethodCacher
  class Railtie < Rails::Railtie
    initializer 'methodcacher.model_additions' do
      ActiveSupport.on_load :active_record do
        include ModelAdditions
      end
    end
  end
end

