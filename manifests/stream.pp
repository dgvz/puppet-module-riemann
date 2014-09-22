define riemann::stream(
		$content
) {
	file { "/etc/riemann/streams.d/${name}.config":
		ensure  => file,
		content => "# This file is Puppet-managed\n\n${content}\n",
		mode    => 0444,
		owner   => "root",
		group   => "root",
	}
}
