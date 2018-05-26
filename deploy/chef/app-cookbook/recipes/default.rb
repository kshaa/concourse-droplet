include_recipe '::persist'

last_update = %x{stat -c %Y /run/chef-package-update 2> /dev/null}.to_i

if Time.now.to_i - last_update > 3600*24
  include_recipe '::packages'
  include_recipe '::docker'
  include_recipe 'docker_compose::installation'

  bash 'package update mark' do code 'touch /run/chef-package-update' end
end

include_recipe '::app'
