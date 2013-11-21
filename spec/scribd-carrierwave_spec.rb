require File.join(File.dirname(__FILE__), %w[spec_helper])

class MockUploader
end

class TestUploader
  include ScribdCarrierWave

  def self.after(*args); end
  def self.before(*args); end
end

describe ScribdCarrierWave do
  context "module methods" do
    before(:each) do
      @uploader = mock
      @uploader.stubs(:class).returns(MockUploader)
      MockUploader.stubs(:public?).returns(false)
      @scribd_user_mock = mock
      Scribd::User.stubs(:login).returns(@scribd_user_mock)
    end

    describe "class methods" do
      it "responds to public?" do
        TestUploader.should respond_to :public?
      end

      it "defaults to private" do
        TestUploader.public?.should be_false
      end

      it "responds to has_ipaper" do
        TestUploader.should respond_to :has_ipaper
      end

      it "sets public correctly" do
        TestUploader.class_eval do
          has_ipaper true
        end
        TestUploader.public?.should be_true
      end

    end
    
    describe "upload" do
      it "calls rscribd.upload with the correct arguments" do
        @uploader.stubs(:url).returns('test_url')
        @uploader.stubs(:root).returns('/root/path/')
        uploader_class = mock
        uploader_class.stubs(:public).returns(false)
        @uploader.class.stubs(:class).returns(uploader_class)
        @scribd_user_mock.expects(:upload).with(has_entries(file: '/root/path/test_url', access: 'private'))
        ScribdCarrierWave::upload @uploader
      end

      it "handles URLs with query parameters correctly" do
        @uploader.stubs(:url).returns('http://example.com/file.pdf?AWSSTUFFBREAKS=TRUE')
        @scribd_user_mock.expects(:upload).with(has_entries(type: 'pdf'))
        ScribdCarrierWave::upload @uploader
      end

      it "makes a private file if public? returns false" do
        @uploader.stubs(:url).returns('http://whatever')
        MockUploader.stubs(:public?).returns(false)
        @scribd_user_mock.expects(:upload).with(has_entries(access: 'private'))
        ScribdCarrierWave::upload @uploader
      end

      it "makes a public file if public? returns true" do
        @uploader.stubs(:url).returns('http://whatever')
        MockUploader.stubs(:public?).returns(true)
        @scribd_user_mock.expects(:upload).with(has_entries(access: 'public'))
        ScribdCarrierWave::upload @uploader
      end
    end
    
    describe "destroy" do
      it "gets the correct document to destroy and calls destroy" do
        @uploader.stubs(:ipaper_id).returns('test_id')
        document = mock
        document.expects(:destroy)
        @scribd_user_mock.expects(:find_document).with('test_id').returns document
        ScribdCarrierWave::destroy @uploader
      end
    end
    
    describe "full_path" do
      it "returns the full file path for file storage" do
        @uploader.stubs(:url).returns('/test/path.pdf')
        @uploader.stubs(:root).returns('/full/path')
        ScribdCarrierWave::full_path(@uploader).should eq '/full/path/test/path.pdf'
      end
      
      it "returns the url for fog storage" do
        @uploader.stubs(:url).returns('http://www.test.com/file.pdf')
        @uploader.stubs(:root).returns('/full/path')
        ScribdCarrierWave::full_path(@uploader).should eq 'http://www.test.com/file.pdf'
      end
    end
  end

  context "class methods" do
    it "responds to has_ipaper" do

    end
  end
  
  context "instance methods" do
    before(:each) do
      @uploader = CarrierWave::Uploader::Base.new
      @uploader.class_eval{has_ipaper}
      @model = mock
      @uploader.stubs(:model).returns(@model)
      @mounted_as = :test_model
      @uploader.stubs(:mounted_as).returns(@mounted_as)
    end
    
    describe "upload_to_scribd" do
      it "calls upload" do
        res = mock
        res.stubs(:doc_id).returns("test_id")
        res.stubs(:access_key).returns("test_access_key")
        @model.expects(:update_attributes).with(has_entries('test_model_ipaper_id' => 'test_id', 
                                                            'test_model_ipaper_access_key' => 'test_access_key'))
                                          .returns true
        ScribdCarrierWave.expects(:upload).with(@uploader).returns(res)
        @uploader.upload_to_scribd nil
      end
    end

    describe "delete_from_scribd" do
      it "calls destroy" do
        ScribdCarrierWave.expects(:destroy).with(@uploader)
        @uploader.delete_from_scribd
      end
    end

    describe "display_ipaper" do
      before(:each) do
        @uploader.stubs(:ipaper_id).returns('test_id')
        @uploader.stubs(:ipaper_access_key).returns('test_access_key')
      end

      it "returns an html string with the ipaper_id and ipaper_access_key included" do      
        html = @uploader.display_ipaper
        html.should match /test_id/
        html.should match /test_access_key/
      end

      it "sets the correct html id attributes" do
        html = @uploader.display_ipaper({id: 'test_id'})
        html.should match /id="embedded_flashtest_id"/
      end
      
      it "does not add the id as a param" do
        html = @uploader.display_ipaper({id: 'test_id'})
        html.should_not match /scribd_doc.addParam\('id', 'test_id'\)/
      end
      
      it "adds string params correctly" do
        html = @uploader.display_ipaper({test_param: 'test_value'})
        html.should match /scribd_doc.addParam\('test_param', 'test_value'\)/
      end
      
      it "adds boolean params correctly" do        
        html = @uploader.display_ipaper({test_param: true})
        html.should match /scribd_doc.addParam\('test_param', true\)/
      end
      
      it "adds integer params correctly" do
        html = @uploader.display_ipaper({test_param: 1})
        html.should match /scribd_doc.addParam\('test_param', 1\)/
      end
    end
    
    describe "fullscreen_url" do
      before(:each) do
        @uploader.stubs(:ipaper_id).returns('test_id')
        @uploader.stubs(:ipaper_access_key).returns('test_access_key')
      end
      
      it "returns the correct url" do
        @uploader.fullscreen_url.should match /http:\/\/www.scribd.com\/fullscreen\/test_id\?access_key=test_access_key/
      end
    end

    describe "ipaper_id" do
      it "should return the value of the model's attribute" do
        @model.expects(:test_model_ipaper_id)
        @uploader.ipaper_id
      end
    end

    describe "ipaper_access_key" do
      it "should return the value of the model's attribute" do
        @model.expects(:test_model_ipaper_access_key)
        @uploader.ipaper_access_key
      end
    end
  end  
end