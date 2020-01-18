framework:
	bazel build --config=ios_arm64 --define 3D=true --cxxopt='-std=c++14' mediapipe/develop:Mediapipe
	cd bazel-bin/mediapipe/develop/ &&\
	rm -rf Mediapipe.framework &&\
	unzip Mediapipe.zip