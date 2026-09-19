gem "tailwindcss-rails"
gem "json", "2.21.1"
gem "slim-rails"

after_bundle do
  say "Installing Tailwind CSS..."

  rails_command "tailwindcss:install"

  say "Installing daisyUI scaffold templates..."
  scaffold_templates = File.expand_path("daisyslim/templates/scaffold", __dir__)
  Dir.children(scaffold_templates).each do |filename|
    copy_file(
      File.join(scaffold_templates, filename),
      File.join("lib/templates/slim/scaffold", filename)
    )
  end

  say "Converting the application layout to Slim..."
  remove_file "app/views/layouts/application.html.erb"
  create_file "app/views/layouts/application.html.slim", <<~SLIM
    doctype html
    html
      head
        title = content_for(:title) || Rails.application.class.module_parent_name.titleize
        meta name="viewport" content="width=device-width,initial-scale=1"
        meta name="apple-mobile-web-app-capable" content="yes"
        meta name="application-name" content=Rails.application.class.module_parent_name.titleize
        meta name="mobile-web-app-capable" content="yes"
        = csrf_meta_tags
        = csp_meta_tag

        = yield :head

        / Enable the PWA manifest in config/routes.rb before uncommenting this link.
        / = tag.link rel: "manifest", href: pwa_manifest_path(format: :json)

        link rel="icon" href="/icon.png" type="image/png"
        link rel="icon" href="/icon.svg" type="image/svg+xml"
        link rel="apple-touch-icon" href="/icon.png"

        = stylesheet_link_tag :app, "data-turbo-track": "reload"
        = javascript_importmap_tags
      body
        main.container.mx-auto.mt-28.px-5.flex
          = yield
  SLIM

  say "Downloading daisyUI..."
  daisyui_version = "5.7.38"
  daisyui_dir = "app/assets/tailwind"
  daisyui_base_url = "https://github.com/saadeghi/daisyui/releases/download/v#{daisyui_version}"

  system(
    "curl",
    "-fsSL",
    "-o",
    "#{daisyui_dir}/daisyui.mjs",
    "#{daisyui_base_url}/daisyui.mjs"
  ) || raise("Failed to download daisyui.mjs")

  system(
    "curl",
    "-fsSL",
    "-o",
    "#{daisyui_dir}/daisyui-theme.mjs",
    "#{daisyui_base_url}/daisyui-theme.mjs"
  ) || raise("Failed to download daisyui.mjs")

  say "Configuring Tailwind CSS..."

  create_file "app/assets/tailwind/application.css", <<~CSS, force: true
    @import "tailwindcss";

    @plugin "./daisyui.mjs";
    @plugin "./daisyui-theme.mjs";
  CSS

  say "Tailwind CSS + daisyUI #{daisyui_version} installed successfully"
end
