# htcondor::config::scheduler
class htcondor::config::worker {
  include htcondor::config::security

  # general - manifest or 1 or more configs
  $condor_user               = $htcondor::condor_user
  $condor_group              = $htcondor::condor_group
  $health_check_script       = $htcondor::health_check_script
  # /etc/condor/config.d/20_workernode.config
  $custom_machine_attributes = $htcondor::custom_machine_attributes
  $custom_job_attributes     = $htcondor::custom_job_attributes
  $daemon_list               = $htcondor::config::daemon_list
  $enable_cgroup             = $htcondor::enable_cgroup
  $proportional_swap_assignment = $htcondor::proportional_swap_assignment
  $htcondor_cgroup           = $htcondor::htcondor_cgroup
  $enable_healthcheck        = $htcondor::enable_healthcheck
  $machine_owner             = $htcondor::machine_owner
  $memory_overcommit         = $htcondor::memory_overcommit
  $number_of_cpus            = $htcondor::number_of_cpus
  $start                     = $htcondor::start
  $partitionable_slots       = $htcondor::partitionable_slots
  $slots                     = $htcondor::slots
  $memory                    = $htcondor::memory
  $job_renice_increment      = $htcondor::job_renice_increment
  $primary_accounts          = $htcondor::primary_accounts
  $starter_job_environment   = $htcondor::starter_job_environment
  $manage_selinux            = $htcondor::manage_selinux
  $pool_create               = $htcondor::pool_create
  $pool_home                 = $htcondor::pool_home
  $use_pid_namespaces        = $htcondor::use_pid_namespaces
  $mount_under_scratch_dirs  = $htcondor::mount_under_scratch_dirs
  # /etc/condor/config.d/50_singularity.config
  $use_singularity           = $htcondor::use_singularity
  $singularity_path          = $htcondor::singularity_path
  $force_singularity_jobs    = $htcondor::force_singularity_jobs
  $singularity_image_expr    = $htcondor::singularity_image_expr
  $singularity_bind_paths    = $htcondor::singularity_bind_paths
  $singularity_target_dir    = $htcondor::singularity_target_dir
  # template files
  $template_workernode       = $htcondor::template_workernode
  $template_singularity      = $htcondor::template_singularity

  file { '/etc/condor/config.d/20_workernode.config':
    content => template($template_workernode),
    require => Package['condor'],
    owner   => $condor_user,
    group   => $condor_group,
    mode    => '0644',
  }

  if $use_singularity {
    file { '/etc/condor/config.d/50_singularity.config':
      content => template($template_singularity),
      require => Package['condor'],
      owner   => $condor_user,
      group   => $condor_group,
      mode    => '0644',
    }
  }

  file { '/usr/local/bin/healhcheck_wn_condor':
    source => $health_check_script,
    owner  => $condor_user,
    group  => $condor_group,
    mode   => '0755',
  }

  if $pool_create {
    $condor_directories = [
      $pool_home,
      '/etc/condor/persistent']
    file { "${pool_home}/condor":
      ensure  => directory,
      owner   => 'condor',
      mode    => '0644',
      seltype => 'condor_var_lib_t',
      require => File[$pool_home],
    }
    if $manage_selinux {
      selinux::fcontext { 'htcondor-pool-selinux':
        seltype  => 'condor_var_lib_t',
        pathspec => "${pool_home}/condor(/.*)?",
      }
      ->selinux::exec_restorecon { "${pool_home}/condor":
        recurse     => true,
        refreshonly => true,
        require     => File["${pool_home}/condor"],
      }
    }
  } else {
    $condor_directories = ['/etc/condor/persistent']
  }

  file { $condor_directories:
    ensure => directory,
    owner  => $condor_user,
    group  => $condor_group,
    mode   => '0644',
  }
}
