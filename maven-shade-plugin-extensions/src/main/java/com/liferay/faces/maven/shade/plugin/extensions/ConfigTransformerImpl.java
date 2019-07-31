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
package com.liferay.faces.maven.shade.plugin.extensions;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.jar.JarEntry;
import java.util.jar.JarOutputStream;

import org.apache.maven.plugins.shade.relocation.Relocator;
import org.apache.maven.plugins.shade.resource.ResourceTransformer;


/**
 * @author  Kyle Stiemann
 */
public class ConfigTransformerImpl implements ResourceTransformer {

	// Private Constants
	private static final String WEB_FRAGMENT = "web-fragment.xml";
	private static final String FACES_CONFIG = "faces-config.xml";
	private static final String META_INF = "META-INF/";

	// Private Data Members
	private long id = 0;
	private Map<String, Path> configFiles = new HashMap<>();

	@Override
	public boolean canTransformResource(String resource) {
		return (resource.startsWith(META_INF) && resource.endsWith("." + FACES_CONFIG)) ||
			resource.equals(META_INF + FACES_CONFIG) || resource.endsWith(META_INF + WEB_FRAGMENT);
	}

	@Override
	public boolean hasTransformedResource() {
		return !configFiles.isEmpty();
	}

	@Override
	public void modifyOutputStream(JarOutputStream jarOutputStream) throws IOException {

		try {
			configFiles.entrySet().stream().forEach((entry) -> {

				try {

					jarOutputStream.putNextEntry(new JarEntry(entry.getKey()));
					Files.copy(entry.getValue(), jarOutputStream);
					jarOutputStream.closeEntry();
				}
				catch (IOException ioException) {
					throw new UncheckedIOException(ioException);
				}
			});
		}
		catch (UncheckedIOException e) {
			throw e.getCause();
		}
	}

	@Override
	public void processResource(String resource, InputStream inputStream, List<Relocator> relocators)
		throws IOException {

		if (canTransformResource(resource)) {

			StringBuilder stringBuilder = new StringBuilder();
			stringBuilder.append(META_INF + "a");
			stringBuilder.append(id++);

			if (!resource.endsWith("." + FACES_CONFIG)) {
				stringBuilder.append(".");
			}

			String configName = resource.replace(META_INF, "");
			stringBuilder.append(configName);

			File tempFacesConfigFile = File.createTempFile("tmp", configName);
			tempFacesConfigFile.deleteOnExit();

			Path tempFacesConfigPath = tempFacesConfigFile.toPath();
			Files.copy(inputStream, tempFacesConfigPath, StandardCopyOption.REPLACE_EXISTING);

			Path facesConfigFile = configFiles.put(stringBuilder.toString(), tempFacesConfigPath);
			assert facesConfigFile == null;
		}
	}
}
