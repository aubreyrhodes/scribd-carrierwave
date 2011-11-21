module ScribdCarrierWave
  class << self
    def config(&block)
      yield configatron.cover_me if block_given?
      configatron.cover_me
    end
  end
end