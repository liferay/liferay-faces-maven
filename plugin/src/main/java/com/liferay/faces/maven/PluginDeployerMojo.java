/**
 * Copyright (c) 2000-2019 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
package com.liferay.faces.maven;

import java.io.File;
import java.io.FileFilter;
import java.util.Properties;

import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.project.MavenProject;


/**
 * Deploys (copies) a Plugin to the $LIFERAY_HOME/deploy folder.
 *
 * @author  Mika Koivisto
 * @author  Thiago Moreira
 * @goal    deploy
 */

public class PluginDeployerMojo extends AbstractLiferayMojo {

	/**
	 * @parameter  expression="${liferayVersion}"
	 */
	protected String liferayVersion;

	/**
	 * @parameter  expression="${project}"
	 * @required
	 * @readonly
	 */
	protected MavenProject project;

	/**
	 * @parameter  expression="${autoDeployDir}"
	 * @required
	 */
	private File autoDeployDir;

	/**
	 * @parameter  expression="${configsDeployDir}"
	 * @required
	 */
	private File configsDeployDir;

	/**
	 * @parameter  default-value="${project.basedir}/src/main/resources/configs" expression="${configsDir}"
	 * @required
	 */
	private File configsDir;

	/**
	 * @parameter  default-value="${project.build.directory}/${project.build.finalName}.war" expression="${warFile}"
	 * @required
	 */
	private File warFile;

	/**
	 * @parameter  default-value="${project.build.finalName}.war" expression="${warFileName}"
	 * @required
	 */
	private String warFileName;

	public void execute() throws MojoExecutionException {

		String packaging = project.getPackaging();

		if (packaging.equals("pom")) {

			if (configsDir.exists()) {
				File[] configFiles = configsDir.listFiles(new FileFilter() {
							@Override
							public boolean accept(File pathname) {
								return (pathname != null) && pathname.isFile() &&
									pathname.getName().endsWith(".config");
							}
						});

				for (File configFile : configFiles) {
					String configFileName = configFile.getName();
					getLog().info("FAST Deploying " + configFileName + " to " + configsDeployDir);
					CopyTask.copyFile(configFile, configsDeployDir, configFileName, null, true, true);
				}
			}
		}
		else {

			if (skipDeploy()) {
				return;
			}

			if (warFile.exists()) {

				String destinationFileName = warFileName;
				destinationFileName = destinationFileName.replaceFirst("-SNAPSHOT", "");
				destinationFileName = destinationFileName.replaceFirst("-(\\d+\\.)*(\\d+).war$", ".war");
				destinationFileName = destinationFileName.replaceFirst("-(\\d+\\.)*(\\d+).jar$", ".jar");
				getLog().info("FAST Deploying " + warFileName + " to " + autoDeployDir);
				CopyTask.copyFile(warFile, autoDeployDir, destinationFileName, null, true, true);
			}
			else {
				getLog().warn(warFileName + " does not exist");
			}
		}
	}

	protected boolean skipDeploy() {

		Properties properties = project.getProperties();
		String mavenSkipDeployProperty = properties.getProperty("maven.deploy.skip");

		if ("true".equalsIgnoreCase(mavenSkipDeployProperty)) {
			getLog().info("Skipping " + project.getArtifactId() + " since maven.deploy.skip=true");

			return true;
		}

		return false;
	}
}
