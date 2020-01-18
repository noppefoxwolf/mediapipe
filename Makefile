framework:
	bazel build --config=ios_arm64 --cxxopt='-std=c++14' mediapipe/develop:MyFramework
	cd bazel-bin/mediapipe/develop/ &&\
	rm -rf MyFramework.framework &&\
	unzip MyFramework.zip &&\
	cd MyFramework.framework &&\
	ar -dv MyFramework  NSError+util_status_f64093ca561b3913726e4e3728906dd8.o