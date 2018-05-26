filesystem 'persist' do
  fstype 'ext4'
  device '/dev/disk/by-id/scsi-0DO_Volume_persist'
  mount '/mnt/persist'
  action [:create, :enable, :mount]
end
