define riemann::def(
		$content
) {
	if $name =~ /^\d{2}-/ {
		$bits = split($name, '-', 2)
		$ordinal = to_i($bits[0]) + 100
		$var     = $bits[1]
	} else {
		$ordinal = 100
		$var = $name
	}

	bitfile::bit {
		"riemann.config def ${name}":
			path    => "/etc/riemann/riemann.config",
			ordinal => $ordinal,
			content => "(def $var $content)";
	}
}
