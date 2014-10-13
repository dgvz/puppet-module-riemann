# Spawn a riemann-health agent to send metrics to a riemann server.
#
# A single riemann-health agent can only send results to one riemann server,
# so if you want to do redundant monitoring, you'll want multiple resources.
#
# Attributes:
#
#  * `server` (string; required)
#
#     The name or address of the riemann server to send events to.
#
#  * `server_port` (integer; optional; default `5555`)
#
#     The TCP port of the riemann server to send events to.
#
define riemann::agent::health(
		$server,
		$server_port = 5555,
) {
	include riemann::tools

	daemontools::service {
		"riemann-health-${name}":
			user    => "root",
			command => "/usr/local/bin/riemann-health --host ${server} --port ${server_port}",
	}
}
