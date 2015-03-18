node default {
  #
  # Define defaults for packages and services.
  #
  Package {
    ensure => 'installed',
    allow_virtual => false
  }

  Service {
    ensure => 'running',
    enable => true
  }

  #
  # Add EPEL repository and install Nginx.
  #
  yumrepo { 'epel':
    baseurl => 'http://dl.fedoraproject.org/pub/epel/6/x86_64',
    descr => 'Extra Packages for Enterprise Linux',
    enabled => 1,
    gpgcheck => 0
  }

  package { 'nginx': require => Yumrepo['epel'] }

  #
  # Install other important/useful packages.
  #
  $packages = [
    'git',
    'mysql-server',
    'nodejs',
    'npm',
    'php-fpm',
    'php-gd',
    'php-mbstring',
    'php-mcrypt',
    'php-mysql',
    'php-pdo',
    'php-pear',
    'php-xml'
  ]
  package { $packages: }

  #
  # Copy SSH keys into root user home directory (if source files exist).
  #
  file { '/root/.ssh': ensure => 'directory' }

  $id_rsa = file('/vagrant/puppet/files/root/.ssh/id_rsa', '/dev/null')
  $id_rsa_pub = file('/vagrant/puppet/files/root/.ssh/id_rsa.pub', '/dev/null')

  if ($id_rsa != '') {
    file { '/root/.ssh/id_rsa':
      content => $id_rsa,
      mode => '0600',
      require => File['/root/.ssh']
    }
  }

  if ($id_rsa_pub != '') {
    file { '/root/.ssh/id_rsa.pub':
      content => $id_rsa_pub,
      mode => '0600',
      require => File['/root/.ssh']
    }
  }

  #
  # Put useful shell scripts in /usr/local/bin.
  #
  file { '/usr/local/bin/git-subrepo-status':
    source => '/vagrant/puppet/files/git/git-subrepo-status',
    owner => 'root',
    group => 'root',
    mode => '0755'
  }

  #
  # Put an example virtual host file in /etc/nginx.
  #
  file { '/etc/nginx/vhost-example.conf':
    source => '/vagrant/puppet/files/nginx/vhost-example.conf',
    owner => 'root',
    group => 'root',
    mode => '0644',
    require => Package['nginx']
  }

  #
  # Start services.
  #
  service { 'nginx': require => Package['nginx'] }
  service { 'php-fpm': require => Package['php-fpm'] }
  service { 'mysqld': require => Package['mysql-server'] }

  # Turn the firewall off so that we don't have to punch a hole in it just to
  # get a local development environment working.
  service { 'iptables': ensure => 'stopped' }
}
