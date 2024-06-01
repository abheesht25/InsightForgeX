FROM xcode:latest
WORKDIR /
COPY . /
RUN xcodebuild
