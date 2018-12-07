ActiveAdmin.register Page do
  menu parent: 'Website Config'

  permit_params :heading, :url, :meta_title, :meta_description, :short_intro, :content,
    :banner, :banner_cache, :thumb, :menu_title, :menu_position, :menu_sort_order, :active,
    attachment_attributes: [:id, :name, :name_cache, :_destroy]

  filter :heading

  controller do
    before_action :set_page, except: [:index, :new, :create]
    before_action :set_pages_count, only: [:new, :edit]

    private
      def set_page
        @page = Page.friendly.find(params[:id])
      end

      def set_pages_count
        @pages_count = Page.count
      end
  end

  index do
    selectable_column
    column :id
    column :heading
    column :created_at
    actions
  end

  form do |f|
    f.inputs "Page" do
      f.input :heading
      f.input :url
      f.input :meta_title
      f.input :meta_description
      f.input :short_intro
      f.input :content, as: :html_editor
      f.input :banner, as: :file, hint: f.object.banner_uploader_hint.html_safe
      f.input :banner_cache, as: :hidden

      f.fields_for :attachment, (f.object.attachment || f.object.build_attachment) do |attachment|
        attachment.input :name, label: "Thumb", hint: f.object.attachment_uploader_hint.html_safe,
          required: false
        attachment.input :name_cache, as: :hidden
      end

      f.input :menu_title
      f.input :menu_position, as: :select, collection: ['top', 'bottom', 'both'], prompt: '- Please select -'
      f.input :menu_sort_order
      f.input :active
    end

    f.actions
  end

  show do
    attributes_table do
      row :heading
      row :url
      row :meta_title
      row :meta_description
      row :short_intro
      row :content
      row :menu_title
      row :menu_position
      row :menu_sort_order
      row :active
      row :created_at
      row :updated_at
      row :thumb do |page|
        if page.attachment
          image_tag page.attachment.name.url(:thumb)
        else
          'No thumbnail'
        end
      end

      row :banner do |page|
        image_tag page.banner.url(:large)
      end
    end
  end
end