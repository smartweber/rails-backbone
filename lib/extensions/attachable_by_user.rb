module AttachableByUser
  extend ActiveSupport::Concern

  included do
    has_many :attachments, as: :attachable, dependent: :destroy, class_name: 'UserAttachment'
    after_save :set_attachments
    attr_accessor :attachment_ids

    def set_attachment(id)
      attachment = UserAttachment.where(id: id).first
      attachment.update_attributes(attachable: self) if attachment
    end

    def set_attachments
      unless attachment_ids.nil? or attachment_ids.empty?
        attachment_ids.each{ |id| self.set_attachment(id) }
      end
    end

    def attachments=(attachments)
      attributes = {type_of_attachment: 'image', attachable: self, user_id: self.user_id}
      arr = attachments.map do |obj|
        if obj.is_a?(ActionDispatch::Http::UploadedFile)
          UserAttachment.new(attributes.merge(image: obj))
        elsif obj.is_a?(String)
          fileless_io = FilelessIO.new(obj)
          UserAttachment.new(attributes.merge(image: fileless_io))
        else
          obj
        end
      end
      super(arr)
    end
  end
end
