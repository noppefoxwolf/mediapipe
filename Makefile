framework:
	bazel build --config=ios_fat --define 3D=true mediapipe/develop:HandTracker
	cd bazel-bin/mediapipe/develop/ &&\
	rm -rf HandTracker.framework &&\
	unzip HandTracker.zip