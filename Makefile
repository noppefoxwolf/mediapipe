framework:
	bazel build --config=ios_fat --define 3D=true mediapipe/develop:Mediapipe
	cd bazel-bin/mediapipe/develop/ &&\
	rm -rf Mediapipe.framework &&\
	unzip Mediapipe.zip