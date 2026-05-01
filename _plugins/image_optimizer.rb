require 'fileutils'
require 'pathname'

Jekyll::Hooks.register :pages, :post_write do |page|
  next unless page.destination.end_with?('.html')

  dest_dir = File.dirname(page.destination)
  source_dir = File.join(page.site.dest, '..')

  # Copy and optimize images referenced in HTML
  html = File.read(page.destination)
  html.scan(/\/assets\/images\/([^\s"')]+)/) do |match|
    image_path = match[0]
    source_image = File.join(source_dir, image_path)

    if File.exist?(source_image)
      dest_image = File.join(dest_dir, image_path)
      FileUtils.mkdir_p(File.dirname(dest_image))
      FileUtils.cp(source_image, dest_image)

      # Trigger optimization (will be done by separate script)
      puts "🖼️  Copied image: #{image_path}"
    end
  end
end
