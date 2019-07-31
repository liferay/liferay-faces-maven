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
import java.nio.file.Files;
import java.util.List;
import java.util.jar.JarOutputStream;
import java.util.zip.ZipEntry;

import org.apache.maven.plugins.shade.relocation.Relocator;
import org.apache.maven.plugins.shade.resource.ManifestResourceTransformer;


/**
 * @author  Kyle Stiemann
 */
public class BNDManifestTransformerImpl extends ManifestResourceTransformer {

	private String bndManifestLocation;
	private boolean transformedManifest = false;

	@Override
	public boolean canTransformResource(String resource) {
		return "META-INF/MANIFEST.MF".equals(resource);
	}

	@Override
	public boolean hasTransformedResource() {
		return true;
	}

	@Override
	public void modifyOutputStream(JarOutputStream jos) throws IOException {

		if (!transformedManifest) {
			jos.putNextEntry(new ZipEntry("META-INF/MANIFEST.MF"));
			Files.copy(new File(bndManifestLocation).toPath(), jos);
			jos.closeEntry();
			transformedManifest = true;
		}
	}

	@Override
	public void processResource(String resource, InputStream is, List<Relocator> relocators) throws IOException {
		// Do nothing.
	}

}
