lint:
	ansible-lint
	antsibull-docs lint-collection-docs --plugin-docs --skip-rstcheck .

role-readme: galaxy.yml roles/tas_single_node/README.j2 roles/tas_single_node/meta/argument_specs.yml roles/tas_single_node/meta/main.yml
	# Trying to put aar_doc in requirements-testing.txt leads to dependency hell,
	# but if we install it in with other tools from requirements-testing.txt, it works fine
	if ! pip list 2>/dev/null | grep aar_doc > /dev/null; then \
		pip install -r requirements-testing.txt; \
		pip install aar_doc --no-deps; \
	fi
	aar_doc --output-template roles/tas_single_node/README.j2 --output-mode replace roles/tas_single_node/ markdown
