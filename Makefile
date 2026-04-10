.PHONY: help install test lint clean run validate

help:
	@echo "CloudBees Unify Metrics Demo - Available Commands"
	@echo "=================================================="
	@echo ""
	@echo "  make install     - Install dependencies"
	@echo "  make test        - Run unit tests with coverage"
	@echo "  make lint        - Run ESLint"
	@echo "  make run         - Start the application"
	@echo "  make validate    - Run all checks (lint + test)"
	@echo "  make clean       - Remove node_modules and coverage"
	@echo ""

install:
	npm install

test:
	npm test

lint:
	npm run lint

run:
	npm start

validate: lint test
	@echo "✅ All validation checks passed!"

clean:
	rm -rf node_modules coverage junit.xml
	@echo "✅ Cleaned up successfully!"
