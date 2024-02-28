switch-8.6.5:
	ghcup set ghc 8.6.5
	ghcup set hls 1.8.0.0

switch-9.8.1:
	ghcup set ghc 9.8.1
	ghcup set hls 2.6.0.0

build-8.6.5: switch-8.6.5
	stack build --stack-yaml stack-v8.6.5.yaml

dist-clean:
	stack clean --full --stack-yaml stack-v8.6.5.yaml
	git clean -Xd -i
