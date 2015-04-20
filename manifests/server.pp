define riemann::server(
	$listen          = "127.0.0.1",
	$graphite_server = undef,
	$mailer          = undef,
) {
	noop {
		"riemann::server/repo": ;
		"riemann::server/installed": ;
		"riemann::server/configured":
			require => Noop["riemann::server/installed"];
	}

	case $::operatingsystem {
		Debian,Ubuntu: {
			apt::source { "riemann":
				location    => "http://riemannpkgs.hezmatt.org/debian",
				release     => "",
				repos       => "riemann/",
				require     => Apt::Key["D999D721201EF605AD8B21C3F774BB18418E2729"],
				before      => Noop["riemann::server/repo"],
				include_src => false,
			}

			apt::key { "D999D721201EF605AD8B21C3F774BB18418E2729":
				key_source => "https://riemannpkgs.hezmatt.org/archive.key",
			}
		}
		RedHat,CentOS: {
			file { "/etc/yum.repos.d/riemann.repo":
				ensure => file,
				source => "puppet:///modules/riemann/etc/yum.repos.d/riemann.repo",
				mode   => 0444,
				owner  => "root",
				group  => "root",
				before => Noop["riemann::server/repo"],
			}
		}
		default: {
			fail "I don't know how to install riemann on '${::operatingsystem}'; patches welcome"
		}
	}

	package { ["riemann", "openjdk-7-jre-headless"]:
		require => Noop["riemann::server/repo"],
		before  => Noop["riemann::server/installed"],
	}

	service { "riemann":
		ensure => "running",
		enable => true,
		hasstatus => true,
		require   => Noop["riemann::server/configured"],
		subscribe => Noop["riemann::server/configured"],
	}

	file {
		"/usr/local/bin/lein":
			ensure => file,
			source => "puppet:///modules/riemann/usr/local/bin/lein",
			mode   => 0555,
			owner  => "root",
			group  => "root",
			before => Noop["riemann::server/installed"];
		"/usr/local/bin/riemann-repl":
			ensure => file,
			source => "puppet:///modules/riemann/usr/local/bin/riemann-repl",
			mode   => 0555,
			owner  => "root",
			group  => "root",
			before => Noop["riemann::server/installed"];
	}

	bitfile { "/etc/riemann/riemann.config":
		mode    => 0444,
		owner   => "root",
		group   => "root",
		require => [
			Noop["riemann::server/installed"]
		],
		before => Noop["riemann::server/configured"],
		notify => Noop["riemann::server/configured"],
	}

	bitfile::bit {
		"riemann.config header":
			path    => "/etc/riemann/riemann.config",
			ordinal => 0,
			content => "; This file is managed by puppet\n; Any changes will be overwritten\n";
		"riemann.config logging":
			path    => "/etc/riemann/riemann.config",
			ordinal => 1,
			content => "(logging/init :file \"/var/log/riemann/riemann.log\")\n";
		"riemann.config tcp-server":
			path    => "/etc/riemann/riemann.config",
			ordinal => 1,
			content => "(tcp-server :host \"${listen}\")";
		"riemann.config udp-server":
			path    => "/etc/riemann/riemann.config",
			ordinal => 1,
			content => "(udp-server :host \"${listen}\")";
		"riemann.config ws-server":
			path    => "/etc/riemann/riemann.config",
			ordinal => 1,
			content => "(ws-server :host \"${listen}\")";
		"riemann.config repl-server":
			path    => "/etc/riemann/riemann.config",
			ordinal => 1,
			content => "(repl-server :host \"127.0.0.1\")";
		"riemann.config periodic-expire":
			path    => "/etc/riemann/riemann.config",
			ordinal => 1,
			content => "(periodically-expire 5)";
		"riemann.config streams let open":
			path    => "/etc/riemann/riemann.config",
			ordinal => 299,
			content => "(let [";
		"riemann config streams let index":
			path    => "/etc/riemann/riemann.config",
			ordinal => 300,
			content => "index (index)";
		"riemann.config streams":
			path    => "/etc/riemann/riemann.config",
			ordinal => 400,
			content => "] (streams include \"/etc/riemann/streams.d\" ))";
	}

	if $graphite_server {
		riemann::def { "graph":
			content => "(graphite {:host \"${$graphite_server}\"})";
		}
	}

	if $mailer {
		$riemann_server_mailer = $mailer

		riemann::def { "email":
			content => template("riemann/etc/riemann/riemann.config_email");
		}
	}
}
