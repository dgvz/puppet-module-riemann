# Install the Riemann tools gem
class riemann::tools {
	package { "riemann-tools":
		provider => gem
	}
}
