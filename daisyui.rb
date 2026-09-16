gem "tailwindcss-rails"
gem "json", "2.21.1"

after_bundle do
  say "Installing Tailwind CSS..."

  rails_command "tailwindcss:install"

  say "Installing daisyUI scaffold templates..."
  scaffold_templates = File.expand_path("daisy/templates/scaffold", __dir__)
  Dir.children(scaffold_templates).each do |filename|
    copy_file(
      File.join(scaffold_templates, filename),
      File.join("lib/templates/erb/scaffold", filename)
    )
  end

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
  ) || raise("Failed to download daisyui-theme.mjs")

  say "Configuring Tailwind CSS..."

  create_file "app/assets/tailwind/application.css", <<~CSS, force: true
    @import "tailwindcss";

    @plugin "./daisyui.mjs";
    @plugin "./daisyui-theme.mjs";
  CSS

  say "Tailwind CSS + daisyUI #{daisyui_version} installed successfully"
end
