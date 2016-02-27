if (Object.const_defined?("Formtastic") && Gem.loaded_specs["formtastic"].version.version[0,1] == "2")

  class RichInput < ::Formtastic::Inputs::TextInput
    def to_html
      scope_type = object.class.name.parameterize.underscore
      scope_id = object.try(:id)
      editor_options = Rich.options(options[:config], scope_type, scope_id)

      input_wrapping do
        label_html <<
        builder.text_area(method, input_html_options) <<
        "<script>CKEDITOR.replace('#{dom_id}', #{editor_options.to_json.html_safe});</script>".html_safe
      end
    end
  end

end

if Object.const_defined?("SimpleForm")
  class RichInput < SimpleForm::Inputs::TextInput
    def input
      scope_type = object.class.name.parameterize.underscore
      scope_id = object.try(:id)
      editor_options = Rich.options(options[:config], scope_type, scope_id)

      super <<
      "<script>CKEDITOR.replace('#{object_name.parameterize.underscore}_#{attribute_name}', #{editor_options.to_json.html_safe});</script>".html_safe
    end
  end
end
