.PHONY: deploy global install uninstall

deploy global install:
	./scripts/deployment.sh --global

uninstall:
	./scripts/deployment.sh --uninstall
