# Configuration of Condor SharedPort service
class htcondor::config::sharedport {
  $use_shared_port            = $htcondor::use_shared_port
  $shared_port                = $htcondor::shared_port
  $shared_port_collector_name = $htcondor::shared_port_collector_name

  $template_sharedport        = $htcondor::template_sharedport
  $managers                   = $htcondor::managers

  $condor_user                = $htcondor::condor_user
  $condor_group               = $htcondor::condor_group

  # SharedPort service configuration
  file { '/etc/condor/config.d/27_shared_port.config':
    content => template($template_sharedport),
    require => Package['condor'],
    owner   => $condor_user,
    group   => $condor_group,
    mode    => '0644',
  }
}
