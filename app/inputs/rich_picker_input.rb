if (Object.const_defined?("Formtastic") && Gem.loaded_specs["formtastic"].version.version[0,1] == "2")

    class RichPickerInput < ::Formtastic::Inputs::StringInput
      include Formtastic::Helpers::InputHelper
      attr_reader :editor_options

      def to_html
        @editor_options = Rich.options(options[:config], object_name, object.id)

        local_input_options = {
          :class => 'rich-picker',
          :style => editor_options[:style]
        }

        input_wrapping do
          label_html <<
          input_field(local_input_options) <<
          button <<
          preview <<
          javascript

        end
      end

    private

      def input_field(local_input_options)
        if editor_options[:hidden_input] == true
          builder.hidden_field(method, local_input_options.merge(input_html_options))
        else
          builder.text_field(method, local_input_options.merge(input_html_options))
        end
      end

      def preview_image_path
        method_value = object.send(method)

        # return placeholder image if this is a non-image picker OR if there is no value set
        return editor_options[:placeholder_image] if editor_options[:type].to_s == 'file'
        return editor_options[:placeholder_image] unless method_value.present?

        column_type = column_for(method).type
        if column_type == :integer
          file = Rich::RichFile.find(method_value)
          file.rich_file.url(:rich_thumb) #we ask paperclip directly for the file, so asset paths should not be an issue
        else # should be :string
          method_value
        end
      end

      def button
        %Q{
            <a href='#{Rich.editor[:richBrowserUrl]}' class='button'>
              #{I18n.t('picker_browse')}
            </a>
        }.html_safe
      end

      def javascript
        %Q{
            <script>
              $(function(){
                $('##{input_html_options[:id]}_input a').click(function(e){
                  e.preventDefault(); assetPicker.showFinder('##{input_html_options[:id]}', #{editor_options.to_json})
                });
              });
            </script>
        }.html_safe
      end

      def preview
        return unless editor_options[:type] != 'file'

        path = preview_image_path
        klass = "class='rich-image-preview'"
        style = "style='max-width:#{editor_options[:preview_size]}; max-height:#{editor_options[:preview_size]};'"
        if path
          %Q{
             </br></br><img src='#{preview_image_path}' #{klass} #{style} />
          }.html_safe
        else
          %Q{
             </br></br><div #{klass} #{style}></div>
          }.html_safe
        end
      end
    end

end

if Object.const_defined?("SimpleForm")
  class RichPickerInput < SimpleForm::Inputs::StringInput
    attr_reader :editor_options, :dom_id

    def input(wrapper_options)
      @editor_options = Rich.options(options[:config], object_name, object.id)
      @dom_id = "#{object_name}_#{attribute_name}"

      local_input_options = merge_wrapper_options({
        :class => 'rich-picker',
        :style => editor_options[:style]
      }, wrapper_options)

      input_field(local_input_options) <<
      button <<
      preview <<
      javascript
    end

  private

    def input_field(local_input_options)
      editor_options[:button_class] ||= 'button'
      if editor_options[:hidden_input] == true
        @builder.hidden_field(attribute_name, local_input_options.merge(input_html_options))
      else
        @builder.text_field(attribute_name, local_input_options.merge(input_html_options))
      end
    end

    def method_value
      object.send(attribute_name)
    end

    def rich_file
      Rich::RichFile.find(method_value)
    end

    def preview_image_path
      # return placeholder image if this is a non-image picker OR if there is no value set
      return editor_options[:placeholder_image] if editor_options[:type].to_s == 'file'
      return editor_options[:placeholder_image] unless method_value.present?

      if method_value.is_a? Integer
        rich_file.rich_file.url(:rich_thumb) #we ask paperclip directly for the file, so asset paths should not be an issue
      else # should be :string
        method_value
      end
    end

    def button
      %Q{
          <a href='#{Rich.editor[:richBrowserUrl]}' class='#{editor_options[:button_class]}'>
            #{I18n.t('picker_browse')}
          </a>
      }.html_safe
    end

    def javascript
      %Q{
          <script>
            $(function(){
              $('.#{dom_id} .#{editor_options[:button_class]}').click(function(e){
                e.preventDefault(); assetPicker.showFinder('##{dom_id}', #{editor_options.to_json})
              });
              $('.rich-image-preview-delete').click(function(e) {
                e.preventDefault();
                if (confirm("#{I18n.t(:delete_confirm)}")) {
                  $('##{dom_id}').val(null);
                  $('.rich-image-preview').attr('src', "#{editor_options[:placeholder_image]}");
                  $('.rich-image-preview-details').hide();
                }
              });
              #{"$('.rich-image-preview-details').hide();" unless method_value.present?}
            });
          </script>
      }.html_safe
    end

    def preview
      return unless editor_options[:type] != 'file'

      path = preview_image_path
      klass = "class='rich-image-preview'"
      style = "style='max-width:#{editor_options[:preview_size]}; max-height:#{editor_options[:preview_size]};'"
      if path
        %Q{
           </br></br><img src='#{preview_image_path}' #{klass} #{style} />
        }.html_safe
      else
        %Q{
           </br></br><div #{klass} #{style}></div>
        }.html_safe
      end +
      "<div class='rich-image-preview-details'>
        <div class='rich-image-preview-filename'>#{rich_file.rich_file_file_name if method_value.present?}</div>
        <a href='#' class='rich-image-preview-delete delete' title=\"#{I18n.t(:delete)}\">delete</a>
       </div>".html_safe
    end
  end
end
