emul:
	fvm flutter emulators --launch Pixel_9

run:
	fvm flutter run

analyze:
	fvm flutter analyze

test: analyze
	fvm flutter test

gitversion:
	docker run --rm -v ./:/app -w /app gittools/gitversion:latest /app
	
build_web:
	fvm flutter build web --release

copy_web_files_to_hosting:
	scp -r build/web/* Norbiox@spiewnikpielgrzyma.norbertchmiel.pl:~/domains/spiewnikpielgrzyma.norbertchmiel.pl/public_html/

deploy_web: build_web copy_web_files_to_hosting
