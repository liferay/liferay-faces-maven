#!/usr/bin/perl -w

################################################################################
#
# Copyright (c) 2000-2015 Liferay, Inc. All rights reserved.
#
# This library is free software; you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation; either version 2.1 of the License, or (at your option)
# any later version.
#
# This library is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
################################################################################

################################################################################
#
# This Perl script is a convenience utility that exists in the top-level folder
# of the liferay-faces project. It parses the project version information from
# the parent-most pom.xml file and fixes version numbers in various type of
# files.
#
################################################################################
#
# Author: Vernon Singleton
#
################################################################################

use strict;
use File::Find;
use POSIX qw(strftime);

#
# Primitives
#
my($liferayFacesVersion,$liferayFacesVersionShort,$liferayFacesVersionShortMajor1DotMajor2,$major1,$major2,$minor);
my($portalVersion,$portalVersionDTD,$portalVersions,$portalDtdDisplay,$portalDtdUrl,$liferayFacesVersionWithoutSnapshot);
my($cdiVersion,$cdiVersionURL,$cdiMajor,$cdiMinor,$facesVersion,$facesVersionURL,$facesMajor,$facesMinor,$portletApi,$portletApiURL,$portletApiMajor,$portletApiMajorDotMinor,$servletApi,$servletApiURL,$servletApiMajor1DotMajor2);
my($liferayFacesMajor1,$liferayFacesMajor2,$liferayFacesMinor,);
my $year= strftime "%Y", localtime;

#
# Parse the project version information from the parent-most POM file.
#
open POM, "pom.xml" or die "cannot open pom.xml: $!\n";
while(<POM>) {

	if (/artifactId>com.liferay.faces..*.parent</) {

		$_ = <POM>;
		/<version>(.*)</;
		$liferayFacesVersion = $1;
		print "liferayFacesVersion = $liferayFacesVersion\n";

		$_ = $liferayFacesVersion;
		s/-SNAPSHOT//;
		$liferayFacesVersionWithoutSnapshot = $_;
		print "liferayFacesVersionWithoutSnapshot = $liferayFacesVersionWithoutSnapshot\n";

		$_ = $liferayFacesVersionWithoutSnapshot;
		s/-(.*)//;
		$liferayFacesVersionShort = $_;
		print "liferayFacesVersionShort = $liferayFacesVersionShort\n";

		($liferayFacesMajor1,$liferayFacesMajor2,$liferayFacesMinor) = split /\./;
		$liferayFacesVersionShortMajor1DotMajor2 = "${liferayFacesMajor1}.${liferayFacesMajor2}";
		print "liferayFacesVersionShortMajor1DotMajor2 = $liferayFacesVersionShortMajor1DotMajor2\n";

	}
	elsif ((/^\t\<version>/) and (!defined $liferayFacesVersion)) {
			/<version>(.*)</;
			$liferayFacesVersion = $1;
	}

	if (/^\t\t<liferay.version>/) {

		/version>(.*)</;
		$portalVersion = $1;
		print "portalVersion = $portalVersion\n";

		$_ = $portalVersion;

		($major1,$major2,$minor) = split /\./;
		$portalVersions = "${major1}.${major2}.*";
		print "portalVersions = $portalVersions\n";
	}

	if (/^\t\t<liferay.version.dtd>/) {

		/version.dtd>(.*)</;
		$portalVersionDTD = $1;
		print "portalVersionDTD = $portalVersionDTD\n";

		$_ = $portalVersionDTD;

		($major1,$major2,$minor) = split /\./;

		$portalDtdDisplay = "${major1}.${major2}.0";
		print "portalDtdDisplay = $portalDtdDisplay\n";

		$portalDtdUrl = "${major1}_${major2}_0";
		print "portalDtdUrl = $portalDtdUrl\n";

	}

	if(/^\t\t<cdi.version>/) {

		/version>(.*)</;
		$cdiVersion = $1;
		print "cdiVersion = $cdiVersion\n";

		$_ = $cdiVersion;

		($cdiMajor,$cdiMinor) = split /[._-]/;

		if ($cdiMajor == 1 and $cdiMinor == 2) {
			# CDI 1.2 relies on beans_1_1.xsd and never released beans_1_2.xsd
			$cdiVersionURL = "1_1";
		}
		else {
			$cdiVersionURL = "${cdiMajor}_${cdiMinor}";
		}
		print "cdiVersionURL = $cdiVersionURL\n";

	}

	if(/^\t\t<faces.spec.version>/) {

		/version>(.*)</;
		$facesVersion = $1;
		$_ = $facesVersion;

		($facesMajor,$facesMinor) = split /[._-]/;

		$facesVersion = "${facesMajor}.${facesMinor}";
		$facesVersionURL = "${facesMajor}_${facesMinor}";
		print "facesVersion = $facesVersion\n";
		print "facesVersionURL = $facesVersionURL\n";
		print "facesMajor = $facesMajor\n";
		print "facesMinor = $facesMinor\n";
	}

	if(/portlet-api<\/artifactId>/) {

			$_ = <POM>;
			if (/version>(.*)</) {
			$portletApi = $1;
			print "portletApi = $portletApi\n";

			$_ = $portletApi;
			($major1,$minor) = split /\./;
			$_ = $minor;
			($minor) = split /\-/;

			$portletApiURL = "${major1}_${minor}";
			print "portletApiURL = $portletApiURL\n";

			$portletApiMajor = "${major1}";

			$portletApiMajorDotMinor = "${major1}.${minor}";
			print "portletApiMajorDotMinor = $portletApiMajorDotMinor\n";
		}
	}

	if(/servlet-api<\/artifactId>/) {

			$_ = <POM>;
			if (/version>(.*)</) {
			$servletApi = $1;
			print "servletApi = $servletApi\n";

			$_ = $servletApi;
			($major1,$major2,$minor) = split /\./;

			$servletApiURL = "${major1}_${major2}";
			print "servletApiURL = $servletApiURL\n";

			$servletApiMajor1DotMajor2 = "${major1}.${major2}";
			print "servletApiMajor1DotMajor2 = $servletApiMajor1DotMajor2\n";
		}
	}

}
close POM;

#
# For each file in the hierarchy:
#
find(\&do_inplace_edits, ".");

sub do_inplace_edits {

	my $file = $_;

	#
	# If the current file is named "pom.xml" and is not the parent-most POM, then potentially fix the
	# version number specified in the <parent><version>...</version></parent> section.
	#
	if ($file eq "pom.xml" and $File::Find::name ne "./pom.xml" and $File::Find::name !~ /\/target/ and $File::Find::name !~ /\/archetype/) {
		print "$File::Find::name\n";

		my $inParent = 0;
		open OUT, ">pom.xml.tmp" or die "cannot open >pom.xml.tmp: $!\n";
		open IN, "pom.xml" or die "cannot open pom.xml: $!\n";
		while(<IN>) {
			if (/<parent/) { $inParent = 1; }
			if ($inParent == 1 and /<version/) {
				s/ersion>..*</ersion>$liferayFacesVersion</;
				$inParent = 0;
			}
			print OUT;
		}
		close IN;
		close OUT;
		rename("pom.xml.tmp", "pom.xml");
	}

	#
	# If the current file is named "web.xml", then potentially fix the
	# version number specified in the schemaLocation url.
	#
	elsif ((($file eq "web.xml") or ($file =~ m/web[-].*\.xml/)) and ($File::Find::name =~ /\/src/)) {
		print "$File::Find::name\n";
		$_ = $File::Find::name;

		if (/jsf2-cdi/ and $facesMajor eq "2" and $facesMinor eq "1") {
			print "intentionally skipping $File::Find::name with faces version $facesVersion\n";
		} else {
			open OUT, ">web.xml.tmp" or die "cannot open >web.xml.tmp: $!\n";
			open IN, $file or die "cannot open $file: $!\n";
			while(<IN>) {
				if (/web-app_/) {
					s/web-app_\d+_\d+.xsd/web-app_${servletApiURL}.xsd/;
					if (/version="/) {
						s/version="\d+.\d+"/version="${servletApiMajor1DotMajor2}"/;
					} else {
						print OUT;
						$_ = <IN>;
						s/version="\d+.\d+"/version="${servletApiMajor1DotMajor2}"/;
					}
				}
				print OUT;
			}
			close IN;
			close OUT;
			rename("web.xml.tmp", $file);
		}
	}

	#
	# Otherwise, if the current file is named "portlet.xml" then potentially fix the version
	# numbers specified in DOCTYPE line for the DTD.
	#
	elsif ($file eq "portlet.xml" and ($File::Find::name =~ /\/src/)) {
		print "$File::Find::name\n";
		if ($portletApiMajor == 3) {
			`perl -pi -e 's/portlet.portlet-app_2_0.xsd\" version=\"2.0\"/portlet\" version=\"$portletApiMajorDotMinor\"/' $file`;
			`perl -pi -e 's/.portlet-app_2_0.xsd http/ http/' $file`;
			`perl -pi -e 's/portlet-app_2_0/portlet-app_$portletApiURL/' $file`;
			`perl -pi -e 's/java.sun.com/xmlns.jcp.org/g' $file`;
		}
	}

	#
	# Otherwise, if the current file is named "liferay-portlet.xml" then potentially fix the version
	# numbers specified in DOCTYPE line for the DTD.
	#
	elsif ($file eq "liferay-portlet.xml" and ($File::Find::name =~ /\/src/)) {
		print "$File::Find::name\n";
		`perl -pi -e 's/DTD Portlet Application ..*\\/\\/EN/DTD Portlet Application $portalDtdDisplay\\/\\/EN/' $file`;
		`perl -pi -e 's/-portlet-app_..*\\.dtd/-portlet-app_$portalDtdUrl\\.dtd/' $file`;
	}
 
	#
	# Otherwise, if the current file is named "liferay-display.xml" then potentially fix the version
	# numbers specified in DOCTYPE line for the DTD.
	#
	elsif ($file eq "liferay-display.xml" and ($File::Find::name =~ /\/src/)) {
		print "$File::Find::name\n";
		`perl -pi -e 's/DTD Display ..*\\/\\/EN/DTD Display $portalDtdDisplay\\/\\/EN/' $file`;
		`perl -pi -e 's/-display_..*\\.dtd/-display_$portalDtdUrl\\.dtd/' $file`;
	}

	#
	# Otherwise, if the current file is named "liferay-hook.xml" then potentially fix the version
	# numbers specified in DOCTYPE line for the DTD.
	#
	elsif ($file eq "liferay-hook.xml" and ($File::Find::name =~ /\/src/)) {
		print "$File::Find::name\n";
		`perl -pi -e 's/DTD Hook ..*\\/\\/EN/DTD Hook $portalDtdDisplay\\/\\/EN/' $file`;
		`perl -pi -e 's/-hook_..*\\.dtd/-hook_$portalDtdUrl\\.dtd/' $file`;
	}

	#
	# Otherwise, if the current file is named "bnd.bnd" then potentially fix
	# the Bundle-Version
	#
	elsif ($file eq "bnd.bnd") {
		print "$File::Find::name\n";
		`perl -pi -e 's/Bundle-Version:..*/Bundle-Version: $liferayFacesVersionWithoutSnapshot/' $file`;
	}

	#
	# Otherwise, if the current file is named "liferay-plugin-package.properties" then potentially fix
	# the version wildcard that indicates compatible versions of Liferay Portal as well as the Bundle-Version.
	#
	elsif ($file eq "liferay-plugin-package.properties" and ($File::Find::name =~ /\/src/) and ($File::Find::name !~ /\/archetype/)) {
		print "$File::Find::name\n";
		`perl -pi -e 's/liferay-versions=..*/liferay-versions=$portalVersions/' $file`;
		`perl -pi -e 's/Bundle-Version:..*/Bundle-Version: $liferayFacesVersionWithoutSnapshot/' $file`;
	}

	#
	# Otherwise, if the current file is named "friendly-url-routes.xml" then potentially fix the version
	# numbers specified in DOCTYPE line for the DTD.
	#
	elsif ($file eq "friendly-url-routes.xml" and ($File::Find::name =~ /\/src/)) {
		print "$File::Find::name\n";
		`perl -pi -e 's/DTD Friendly URL Routes [0-9][.][0-9][.][0-9]/DTD Friendly URL Routes $portalDtdDisplay/' $file`;
		`perl -pi -e 's/liferay-friendly-url-routes_[0-9]_[0-9]_[0-9][.]dtd/liferay-friendly-url-routes_$portalDtdUrl.dtd/' $file`;
	}

	#
	# Otherwise, if the current file is named "beans.xml" then potentially fix the version number that
	# will appear in the version attribute and the version number that will appear in the xsi:schemaLocation
	# attribute URL of the beans tag.
	#
	elsif (($file eq "beans.xml") and ($File::Find::name =~ /\/src/)) {
		print "$File::Find::name\n";
		# `perl -pi -e 's/beans version=\"[0-9.]+\"/beans version=\"$cdiVersion\"/' $file`;
		`perl -pi -e 's/beans[0-9_]+/beans_$cdiVersionURL/' $file`;
		if ($cdiMajor == 1 and $cdiMinor > 0) {
			`perl -pi -e 's/java.sun.com/xmlns.jcp.org/g' $file`;
		} else {
			`perl -pi -e 's/xmlns.jcp.org/java.sun.com/g' $file`;
		}
		`perl -pi -e 's/xmlns.jcp.org\\/xml\\/ns\\/javaee[ "]\$/xmlns.jcp.org\\/xml\\/ns\\/javaee" bean-discovery-mode="all" version=\"$cdiVersion\"/g' $file`;
	}

	#
	# Otherwise, if the current file is named "faces-config.xml" then potentially fix the version number that
	# will appear in the version attribute faces config tag and potentially fix the version number that will appear in
	# the xsi:schemaLocation attribute URL of the faces config tag.
	#
	elsif ((($file eq "faces-config.xml") or ($file eq "navigation-rule.xml")) and ($File::Find::name =~ /\/src/)) {
		print "$File::Find::name\n";
		`perl -pi -e 's/faces-config version=\"[0-9.]+\"/faces-config version=\"$facesVersion\"/' $file`;
		`perl -pi -e 's/web-facesconfig[0-9_]+/web-facesconfig_$facesVersionURL/' $file`;
		if ($facesMajor == 2 and $facesMinor > 1) {
			`perl -pi -e 's/java.sun.com/xmlns.jcp.org/g' $file`;
		} else {
			`perl -pi -e 's/xmlns.jcp.org/java.sun.com/g' $file`;
		}
	}

	#
	# Otherwise, if the current file is named with .taglib.xml extension, then
	#
	elsif (($file =~ m/.*\.taglib\.xml/) and ($File::Find::name =~ /\/src/)) {
		print "$File::Find::name\n";

		# If the JSF version is 2.1, the Facelet Taglib version is 2.0. See
		# https://issues.liferay.com/browse/FACES-2109#commentauthor_590915_verbose for more details.
		if ($facesMajor eq 2 and $facesMinor eq 1) {
			`perl -pi -e 's/xmlns.jcp.org\\/xml\\/ns\\/javaee/java.sun.com\\/xml\\/ns\\/javaee/g' $file`;
			`perl -pi -e 's/web-facelettaglibrary_[0-9]_[0-9]\\.xsd/web-facelettaglibrary_2_0.xsd/' $file`;
			`perl -pi -e 's/version="[0-9]\\.[0-9]"/version="2.0"/' $file`;
		}
		elsif ($facesMajor > 2 or ($facesMajor == 2 and $facesMinor > 1)) {
			`perl -pi -e 's/java.sun.com\\/xml\\/ns\\/javaee/xmlns.jcp.org\\/xml\\/ns\\/javaee/g' $file`;
			`perl -pi -e 's/web-facelettaglibrary_[0-9]_[0-9]\\.xsd/web-facelettaglibrary_${facesMajor}_${facesMinor}.xsd/' $file`;
			`perl -pi -e 's/version="[0-9]\\.[0-9]"/version="$facesVersion"/' $file`;
		}
	}

	#
	# Otherwise, if the current file is named with .tld extension, then
	#
	elsif (($file =~ m/.*\.tld/) and ($File::Find::name =~ /\/src/)) {
		print "$File::Find::name\n";
		`perl -pi -e 's/tlib-version>[0-9]\\.[0-9]\\.[0-9]/tlib-version>$liferayFacesVersionShort/' $file`;
	}

	#
	# Otherwise, if the current file is named with .xhtml extension, then
	#
	elsif (($file =~ m/.*\.xhtml/) and ($File::Find::name =~ /\/src/)) {
		print "$File::Find::name\n";
		if ($facesMajor > 2 or ($facesMajor == 2 and $facesMinor > 1)) {
			`perl -pi -e 's/java.sun.com/xmlns.jcp.org/g' $file`;
			`perl -pi -e 's/xmlns.jcp.org\\/portlet_2_0/java.sun.com\\/portlet_2_0/g' $file`;
		} else {
			`perl -pi -e 's/xmlns.jcp.org/java.sun.com/g' $file`;
		}
	}

	#
	# Otherwise, if the current file is named NOTICE.txt, then potentially fix the copyright year.
	#
	elsif (($file =~ m/NOTICE.txt/) and ($File::Find::name =~ /\/src/)) {
		print "$File::Find::name\n";
		`perl -pi -e 's/2000-..* Liferay/2000-${year} Liferay/' $file`;
	}

	#
	# Otherwise, if the current file is named with .java extension, then potentially fix the copyright year.
	#
	elsif (($file =~ m/.*\.java/) and ($File::Find::name =~ /\/src/)) {
		print "$File::Find::name\n";
		`perl -pi -e 's/2000-..* Liferay/2000-${year} Liferay/' $file`;
	}

	#
	# Otherwise, if the current file is named generator.properties, then potentially fix the copyright year and the
	# current version.
	#
	elsif ($file eq "generator.properties") {
		print "$File::Find::name\n";
		`perl -pi -e 's/builder[.]copyright[.]year=[0-9]+/builder.copyright.year=${year}/' $file`;
	}

	#
	# Otherwise, if the current file is named with .md extension, then fix the version (if already present).
	#
	elsif (($file =~ m/.*\.md/) and ($File::Find::name =~ /\/src/)) {
		print "$File::Find::name\n";
		`perl -pi -e 's/^_Version:.*/_Version: ${liferayFacesVersion}_/' $file`;
	}
}
