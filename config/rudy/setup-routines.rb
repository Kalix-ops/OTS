
# ----------------------------------------------------------- ROUTINES --------
# The routines block describes the repeatable processes for each machine group.
# To run a routine, specify its name on the command-line: rudy startup
routines do
  
  env :prod do  
    upload_certs do
      remote :root do
        env = $global.environment
        base_path = "config/certs"
        file_upload "#{base_path}/onetimesecret.com.key", "/root/"
        file_upload "#{base_path}/onetimesecret.com.crt", "/root/"
      end
    end
  end
  
  env :dev do  
    upload_certs do
      remote :root do
        env = $global.environment
        base_path = "config/certs"
        file_upload "#{base_path}/onetimesecret.com.key", "/etc/pki/tls/private/"
        file_upload "#{base_path}/onetimesecret.com.crt", "/etc/pki/tls/certs/"
      end
    end
  end
  
  env :proto do
    upload_certs do
      remote :root do
        env = $global.environment
        file_upload "config/environment/#{config_env}/bs-proto-server.crt", "/root/"
        file_upload "config/environment/#{config_env}/bs-proto-server.key", "/root/"
      end
    end
  end
  
  upload_keys  do 
    remote :stella do
      base_path = "config/ssh"
      file_upload "#{base_path}/id_rsa",     '.ssh/'
      file_upload "#{base_path}/id_rsa.pub",  '.ssh/'
      file_upload "config/ssh/known_hosts", '.ssh/'
      wildly { chmod :R, 600, '.ssh/*' }
    end
  end
  
  install_redis do
    remote :root do
      yum 'install', 'redis'
    end
  end
  
  set_nginx_config do
    remote :root do
      if File.exists?('/etc/onetime/config')
        $otsconfig = YAML.load_file('/etc/onetime/config')
      else
        $otsconfig = YAML.load_file('./etc/config')
      end
      $nginx_config = {}
      $nginx_config[:ipaddress] = $otsconfig[:nginx][:ipaddress]
      $nginx_config[:servername] = $otsconfig[:nginx][:servername]
      puts File.expand_path(File.join('config', 'tmpl', 'nginx.conf.tmpl'))
      template_upload File.expand_path(File.join('config', 'tmpl', 'nginx.conf.tmpl')), "/tmp/"
      mv '/tmp/nginx.conf.tmpl', '/etc/nginx/nginx.conf'
      chown 'root:', '/etc/nginx/nginx.conf'
      chmod '644', '/etc/nginx/nginx.conf'
    end
  end

end
