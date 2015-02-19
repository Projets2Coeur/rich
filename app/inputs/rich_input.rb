if (Object.const_defined?("Formtastic") && Gem.loaded_specs["formtastic"].version.version[0,1] == "2")

  class RichInput < ::Formtastic::Inputs::TextInput
    def to_html

      if object
        scope_type = object_name
        scope_id = object.id
        editor_options = Rich.options(options[:config], scope_type, scope_id)
      end

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
      if object
        scope_type = object_name
        scope_id = object.id
        editor_options = Rich.options(options[:config], scope_type, scope_id)
      end

      super <<
      "<script>CKEDITOR.replace('#{object_name}_#{attribute_name}', #{editor_options.to_json.html_safe});</script>".html_safe
    end
  end
end
