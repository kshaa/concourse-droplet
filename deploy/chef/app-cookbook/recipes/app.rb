images_path = '/mnt/persist/images'

ruby 'load up images' do
  cwd images_path

  only_if { File.exists? images_path }

  code <<-EOF
    Dir.glob('fresh/*').each do |image|
      name = File.basename image
      next if File.exists?("loaded/\#{ name }")

      out = IO.popen(%w{docker load -i} + [image], :err=>[:child, :out], &:read)
      raise "\#{ $0 }: docker load -i failed\\n\\n\#{ out }\\n\\n, btw pwd: \#{ %w{docker load -i} + [image] }" unless $?.success?

      File.rename(image, File.join('loaded', name))
      File.open(image, 'w') {}
    end
  EOF
end

# Concourse specific ssh key generation for container connections
execute "generate concourse container ssh keys" do
  command "sh /var/deployment/generate-keys.sh"
end

# Docker container initialisation
execute "initialise the docker composition" do
  command "docker-compose --file /var/deployment/docker-compose.yml up"
end
