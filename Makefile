lint:
	ansible-lint
	antsibull-docs lint-collection-docs --plugin-docs --skip-rstcheck .

role-readme: galaxy.yml roles/tas_single_node/README.j2 roles/tas_single_node/meta/argument_specs.yml roles/tas_single_node/meta/main.yml
	aar_doc --output-template roles/tas_single_node/README.j2 --output-mode replace roles/tas_single_node/ markdown
