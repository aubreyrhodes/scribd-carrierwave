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
      file_path = full_path(uploader)
      args = { file: file_path, access: 'private' }

      type = File.extname(file_path)
      if type
        type = type.gsub(/^\./, '').gsub(/\?.*$/, '')
        args.merge!(type: type) if type != ''
      end

      scribd_user.upload(args)
    end
    
    def destroy uploader
      document = scribd_user.find_document(uploader.ipaper_id) rescue nil
      document.destroy if !document.nil?
    end
    
    def full_path uploader
      if uploader.url =~ /^http(s?):\/\//
        uploader.url
      else
        uploader.root + uploader.url
      end
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
          <script type="text/javascript" src="http://www.scribd.com/javascripts/scribd_api.js"></script>
          <div id="embedded_flash#{id}">#{options.delete(:alt)}</div>
          <script type="text/javascript">
            var scribd_doc = scribd.Document.getDoc(#{ipaper_id}, '#{ipaper_access_key}');
            scribd_doc.addParam( 'jsapi_version', 2 );
            #{options.map do |k,v|
                "          scribd_doc.addParam('#{k.to_s}', #{v.is_a?(String) ? "'#{v.to_s}'" : v.to_s});"
              end.join("\n")}
            scribd_doc.write("embedded_flash#{id}");
          </script>
        END
      end
      
      def fullscreen_url
        "http://www.scribd.com/fullscreen/#{ipaper_id}?access_key=#{ipaper_access_key}"
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
