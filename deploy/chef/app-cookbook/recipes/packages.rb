bash 'apt update' do code 'apt update' end

%w{ntp htop ncdu git pv docker}.each(&method(:package))
