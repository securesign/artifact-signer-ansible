lint:
	ansible-lint
	antsibull-docs lint-collection-docs --plugin-docs --skip-rstcheck .

galaxy-importer-test:
	ansible-galaxy collection build --force
	python -m galaxy_importer.main redhat-artifact_signer-*.tar.gz

role-readme: galaxy.yml roles/tas_single_node/README.j2 roles/tas_single_node/meta/argument_specs.yml roles/tas_single_node/meta/main.yml
	# Trying to put aar_doc in testing-requirements.txt leads to dependency hell,
	# but if we install it in with other tools from testing-requirements.txt, it works fine
	if ! pip list 2>/dev/null | grep aar_doc > /dev/null; then \
		pip install -r testing-requirements.txt; \
		pip install "aar_doc~=2.0" --no-deps; \
	fi
	aar-doc --output-template roles/tas_single_node/README.j2 --output-mode replace roles/tas_single_node/ markdown

readme-preview: role-readme README.md
	python -c "import galaxy_importer.utils.markup; print(galaxy_importer.utils.markup._render_from_markdown(galaxy_importer.utils.markup.get_readme_doc_file('.')))" > README.html
	python -c "import galaxy_importer.utils.markup; print(galaxy_importer.utils.markup._render_from_markdown(galaxy_importer.utils.markup.get_readme_doc_file('roles/tas_single_node/')))" > roles/tas_single_node/README.html
