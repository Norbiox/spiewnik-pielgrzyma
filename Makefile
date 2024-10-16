build_runner:
	flutter pub run build_runner build

emul:
	flutter emulators --launch Pixel_3a_API_34

run:
	flutter run

test:
	flutter analyze

gitversion:
	docker run --rm -v ./:/app -w /app gittools/gitversion:latest /app
	