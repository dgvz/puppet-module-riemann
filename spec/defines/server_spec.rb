require 'spec_helper'

describe "riemann::server" do
	let(:title) { "rspec" }
	let(:facts) { { :operatingsystem => "Debian",
	                :lsbdistid       => "Debian"
	            } }

	context "with no args" do
		it "adds the riemann apt repo" do
			expect(subject).
			  to contain_apt__source("riemann").
			  with_location("http://riemannpkgs.hezmatt.org/debian").
			  with_release("").
			  with_repos("riemann/")
		end

		it "adds the riemann apt key" do
			expect(subject).
			  to contain_apt__key("418E2729").
			  with_key_source("https://riemannpkgs.hezmatt.org/archive.key")
		end

		it "install the package" do
			expect(subject).
			  to contain_package("riemann")
		end

		it "installs riemann-repl" do
			expect(subject).
			  to contain_file("/usr/local/bin/riemann-repl").
			  with_source("puppet:///modules/riemann/usr/local/bin/riemann-repl").
			  with_mode("0555").
			  with_owner("root").
			  with_group("root")
		end

		it "installs lein" do
			expect(subject).
			  to contain_file("/usr/local/bin/lein").
			  with_source("puppet:///modules/riemann/usr/local/bin/lein").
			  with_mode("0555").
			  with_owner("root").
			  with_group("root")
		end

		it "installs a JRE" do
			expect(subject).
			  to contain_package("openjdk-7-jre-headless")
		end

		it "installs a config file" do
			expect(subject).
			  to contain_bitfile("/etc/riemann/riemann.config").
			  with_require("Noop[riemann::server/installed]")
		end
	end

	context "with no args on CentOS" do
		let(:facts) { { :operatingsystem => "CentOS",
		                :lsbdistid       => "CentOS"
		            } }

		it "adds the riemann yum repo" do
			expect(subject).
			  to contain_file("/etc/yum.repos.d/riemann.repo").
			  with_source("puppet:///modules/riemann/etc/yum.repos.d/riemann.repo")
		end
	end
end
