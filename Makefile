lint:
	ansible-lint
	antsibull-docs lint-collection-docs --plugin-docs --skip-rstcheck .

role-readme: galaxy.yml roles/tas_single_node/README.j2 roles/tas_single_node/meta/argument_specs.yml roles/tas_single_node/meta/main.yml
	# Trying to put aar_doc in requirements-testing.txt leads to dependency hell,
	# but if we install it in an existing virtual environment with all the other tools, it just works
	if ! env | grep "VIRTUAL_ENV=" > /dev/null; \
		then echo "Please activate virtualenv and install all dependencies from requirements-testing.txt"; \
		exit 1; \
	fi

	if ! pip list 2>/dev/null | grep aar_doc > /dev/null; then pip install aar_doc; fi
	aar_doc --output-template roles/tas_single_node/README.j2 --output-mode replace roles/tas_single_node/ markdown
