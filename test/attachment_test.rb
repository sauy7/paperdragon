require 'test_helper'

class AttachmentSpec < MiniTest::Spec
  class Attachment < Paperdragon::Attachment
  private
    def uid_from(style)
      "/uid/#{style}"
    end
  end

  describe "existing" do
    subject { Attachment.new({:original => {:uid=>"/uid/1234.jpg"}}) }

    # it { subject[:original].must_be_kind_of Paperdragon::File }
    it { subject[:original].uid.must_equal "/uid/1234.jpg" }
    it { subject[:original].options.must_equal({:uid=>"/uid/1234.jpg"}) }
    it { subject.exists?.must_equal true }
  end

  describe "new" do
    subject { Attachment.new(nil) }

    # it { subject[:original].must_be_kind_of Paperdragon::File }
    it { subject[:original].uid.must_equal "/uid/original" }
    it { subject[:original].options.must_equal({}) }
    it { subject.exists?.must_equal false }
  end


  # test passing options into Attachment and use that in #build_uid.
  class AttachmentUsingOptions < Paperdragon::Attachment
  private
    def build_uid(style)
      "uid/#{style}/#{options[:filename]}"
    end
  end

  # use in new --> build_uid.
  it { AttachmentUsingOptions.new(nil, {:filename => "apotomo.png"})[:original].uid.must_equal "uid/original/apotomo.png" }


  # test using custom File class in Attachment.
  class OverridingAttachment < Paperdragon::Attachment
    class File < Paperdragon::File
      def uid
        "from/file"
      end
    end
    self.file_class= File
  end

  it { OverridingAttachment.new(nil)[:original].uid.must_equal "from/file" }
end


class AttachmentModelSpec < MiniTest::Spec
  class Attachment < Paperdragon::Attachment
    include Paperdragon::Attachment::Model # model.image_meta_data
  private
    def build_uid(style)
      "#{model.class}/uid/#{style}/#{options[:filename]}"
    end
  end

  describe "existing" do
    let (:existing) { OpenStruct.new(:image_meta_data => {:original => {:uid=>"/uid/1234.jpg"}}) }
    subject { Attachment.new(existing) }

    it { subject[:original].uid.must_equal "/uid/1234.jpg" } # notice that #uid_from is not called.
  end

  describe "new" do
    subject { Attachment.new(OpenStruct.new, :filename => "apotomo.png") } # you can pass options into Attachment::new that may be used in #build_uid

    it { subject[:original].uid.must_equal "OpenStruct/uid/original/apotomo.png" }
  end
end