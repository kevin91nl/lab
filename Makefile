init:
	pip install --upgrade --upgrade-strategy eager -r requirements-dev.txt
	git init
	python -m pre_commit install
	pip install -e .
	mkdir -p tests/{unit,integration}

check:
	radon cc src | grep "([6-9])\|([0-9][0-9])\|100" > /tmp/radon_output ; cat /tmp/radon_output ; [ ! -s /tmp/radon_output ] || (echo "Radon cyclomatic complexity score too high" && exit 1)
	radon mi src | grep "\- [B-F]" > /tmp/radon_output ; cat /tmp/radon_output ; [ ! -s /tmp/radon_output ] || (echo "Radon maintainability index too high" && exit 1)
	radon hal src > /tmp/radon_data && python -c "file = open('/tmp/radon_data', 'r'); data = file.read(); file.close(); lines = data.replace('\n    ', ' ').split('\n'); lines = [line for line in lines if 'bugs:' in line and float(line.split('bugs:')[-1].split()[0]) > 0.05]; file = open('/tmp/radon_output', 'w'); file.write('\n'.join(lines).strip()); file.close()" ; cat /tmp/radon_output ; [ ! -s /tmp/radon_output ] || (echo "\nRadon Halstead score too high" && exit 1)
	black --check .
	vulture
	pyflakes .
	pyright

test-doctest:
	python -m pytest src --doctest-modules --exitfirst ; \
	EXIT_STATUS=$$? ; \
	[ "$$EXIT_STATUS" -eq 1 ] && exit 1 || exit 0

test-unit:
	python -m pytest tests/unit --exitfirst ; \
	EXIT_STATUS=$$? ; \
	[ "$$EXIT_STATUS" -eq 1 ] && exit 1 || exit 0

test-integration:
	python -m pytest tests/integration --exitfirst ; \
	EXIT_STATUS=$$? ; \
	[ "$$EXIT_STATUS" -eq 1 ] && exit 1 || exit 0