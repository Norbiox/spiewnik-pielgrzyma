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
