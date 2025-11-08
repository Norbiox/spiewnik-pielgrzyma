emul:
	flutter emulators --launch Pixel_3a_API_34

run:
	flutter run

test:
	flutter analyze

gitversion:
	docker run --rm -v ./:/app -w /app gittools/gitversion:latest /app
	
build_web:
	flutter build web --release

copy_web_files_to_hosting:
	scp -r build/web/* Norbiox@spiewnikpielgrzyma.norbertchmiel.pl:~/domains/spiewnikpielgrzyma.norbertchmiel.pl/public_html/

deploy_web: build_web copy_web_files_to_hosting
