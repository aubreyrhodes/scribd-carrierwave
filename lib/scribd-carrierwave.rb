require File.join(File.dirname(__FILE__), './scribd-carrierwave/version')
require File.join(File.dirname(__FILE__), './scribd-carrierwave/config')
require 'carrierwave'
require 'rscribd'
require 'configatron'

module ScribdCarrierWave
  class << self
    def included(base)
      base.extend ClassMethods
    end
    
    def upload uploader
      args = { file: uploader.url, access: 'private' }
      scribd_user.upload(args)
    end
    
    def destroy uploader
      document = scribd_user.find_document(uploader.ipaper_id) rescue nil
      document.destroy if !document.nil?
    end
    
    module ClassMethods
      def has_ipaper
        include InstanceMethods
        after :store, :upload_to_scribd
        before :remove, :delete_from_scribd
      end
    end
    
    module InstanceMethods
      def self.included(base)
        base.extend ClassMethods
      end
      
      def upload_to_scribd files
        res = ScribdCarrierWave::upload(self)
        set_params res
      end
      
      def delete_from_scribd
        ScribdCarrierWave::destroy(self)
      end

      def display_ipaper(options = {})        
        id = options.delete(:id)
        <<-END
          <script type="text/javascript" src="http://www.scribd.com/javascripts/view.js"></script>
          <div id="embedded_flash#{id}">#{options.delete(:alt)}</div>
          <script type="text/javascript">
            var scribd_doc = scribd.Document.getDoc(#{ipaper_id}, '#{ipaper_access_key}');
            scribd_doc.addParam("hide_disabled_buttons", true)
            scribd_doc.write("embedded_flash#{id}");
          </script>
        END
      end

      def ipaper_id
        self.model.send("#{self.mounted_as.to_s}_ipaper_id")
      end

      def ipaper_access_key
        self.model.send("#{self.mounted_as.to_s}_ipaper_access_key")
      end
      
      private 
      
      def set_params res
        self.model.update_attributes({"#{self.mounted_as}_ipaper_id" => res.doc_id, 
                                      "#{self.mounted_as}_ipaper_access_key" => res.access_key})
      end
    end
    
    private 
    
    def scribd_user
      Scribd::API.instance.key    = ScribdCarrierWave.config.key
      Scribd::API.instance.secret = ScribdCarrierWave.config.secret
      @scribd_user = Scribd::User.login(ScribdCarrierWave.config.username, ScribdCarrierWave.config.password)
    end 
  end
end

CarrierWave::Uploader::Base.send(:include, ScribdCarrierWave) if Object.const_defined?("CarrierWave")
