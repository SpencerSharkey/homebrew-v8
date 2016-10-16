class V8 < Formula
  desc "Google's JavaScript engine"
  homepage "https://code.google.com/p/v8/"
  url "https://github.com/v8/v8/archive/5.4.420.tar.gz"
  sha256 "14f430e99f695ea632b60c946b222bfeac383ce7d205759530bc062cc58b565a"
  head "https://github.com/v8/v8.git"

  bottle do
    root_url "https://github.com/dflemstr/homebrew-v8/releases/download/v5.4.420/"
    sha256 "fc165ebb19bf48be44cf5c45b0790e2d0855a2fe55ebaaba4f5e6bc01e06281f" => :el_capitan
  end

  option "with-readline", "Use readline instead of libedit"

  # not building on Snow Leopard:
  # https://github.com/Homebrew/homebrew/issues/21426
  depends_on :macos => :lion

  depends_on :python => :build # gyp doesn't run under 2.6 or lower
  depends_on "readline" => :optional
  depends_on "icu4c" => :recommended

  needs :cxx11

  # Update from "DEPS" file in tarball.

  # resources definition, do not edit, autogenerated

  resource "mozilla-tests" do
    url "https://chromium.googlesource.com/v8/deps/third_party/mozilla-tests.git",
    :revision => "f6c578a10ea707b1a8ab0b88943fe5115ce2b9be"
  end

  resource "buildtools" do
    url "https://chromium.googlesource.com/chromium/buildtools.git",
    :revision => "adb8bf4e8fc92aa1717bf151b862d58e6f27c4f2"
  end

  resource "inspector_protocol" do
    url "https://chromium.googlesource.com/chromium/src/third_party/WebKit/Source/platform/inspector_protocol.git",
    :revision => "9d440c96636c5a41ce3e40f1924fe41dd2694f51"
  end

  resource "ecmascript_simd" do
    url "https://chromium.googlesource.com/external/github.com/tc39/ecmascript_simd.git",
    :revision => "baf493985cb9ea7cdbd0d68704860a8156de9556"
  end

  resource "mb" do
    url "https://chromium.googlesource.com/chromium/src/tools/mb.git",
    :revision => "c78da3f5bccc979b35907c4cbf937aa5187e41fa"
  end

  resource "googlemock" do
    url "https://chromium.googlesource.com/external/googlemock.git",
    :revision => "0421b6f358139f02e102c9c332ce19a33faf75be"
  end

  resource "clang" do
    url "https://chromium.googlesource.com/chromium/src/tools/clang.git",
    :revision => "6d377a47e9c668c7550d17a7d4e6ba9f5931703a"
  end

  resource "markupsafe" do
    url "https://chromium.googlesource.com/chromium/src/third_party/markupsafe.git",
    :revision => "484a5661041cac13bfc688a26ec5434b05d18961"
  end

  resource "googletest" do
    url "https://chromium.googlesource.com/external/github.com/google/googletest.git",
    :revision => "6f8a66431cb592dad629028a50b3dd418a408c87"
  end

  resource "jinja2" do
    url "https://chromium.googlesource.com/chromium/src/third_party/jinja2.git",
    :revision => "2222b31554f03e62600cd7e383376a7c187967a1"
  end

  resource "build" do
    url "https://chromium.googlesource.com/chromium/src/build.git",
    :revision => "4155375bddb65fe3d2dbc42ab0d64c4d72527165"
  end

  resource "benchmarks" do
    url "https://chromium.googlesource.com/v8/deps/third_party/benchmarks.git",
    :revision => "05d7188267b4560491ff9155c5ee13e207ecd65f"
  end

  resource "gyp" do
    url "https://chromium.googlesource.com/external/gyp.git",
    :revision => "702ac58e477214c635d9b541932e75a95d349352"
  end

  resource "test262" do
    url "https://chromium.googlesource.com/external/github.com/tc39/test262.git",
    :revision => "88bc7fe7586f161201c5f14f55c9c489f82b1b67"
  end

  resource "instrumented_libraries" do
    url "https://chromium.googlesource.com/chromium/src/third_party/instrumented_libraries.git",
    :revision => "f15768d7fdf68c0748d20738184120c8ab2e6db7"
  end

  resource "swarming" do
    url "https://chromium.googlesource.com/external/swarming.client.git",
    :revision => "e4288c3040a32f2e7ad92f957668f2ee3d36e5a6"
  end

  resource "test262-harness-py" do
    url "https://chromium.googlesource.com/external/github.com/test262-utils/test262-harness-py.git",
    :revision => "cbd968f54f7a95c6556d53ba852292a4c49d11d8"
  end

  resource "icu" do
    url "https://chromium.googlesource.com/chromium/deps/icu.git",
    :revision => "53ce631655a61aaaa42b43b4d64abe23e9b8d71f"
  end

  resource "common" do
    url "https://chromium.googlesource.com/chromium/src/base/trace_event/common.git",
    :revision => "315bf1e2d45be7d53346c31cfcc37424a32c30c8"
  end

  def install
    # Bully GYP into correctly linking with c++11
    ENV.cxx11
    ENV["GYP_DEFINES"] = "clang=1 mac_deployment_target=#{MacOS.version}"
    # https://code.google.com/p/v8/issues/detail?id=4511#c3
    ENV.append "GYP_DEFINES", "v8_use_external_startup_data=0"

    if build.with? "icu4c"
      ENV.append "GYP_DEFINES", "use_system_icu=1"
      i18nsupport = "i18nsupport=on"
    else
      i18nsupport = "i18nsupport=off"
    end

    # fix up libv8.dylib install_name
    # https://github.com/Homebrew/homebrew/issues/36571
    # https://code.google.com/p/v8/issues/detail?id=3871
    inreplace "src/v8.gyp",
              "'OTHER_LDFLAGS': ['-dynamiclib', '-all_load']",
              "\\0, 'DYLIB_INSTALL_NAME_BASE': '#{opt_lib}'"

    # resources installation, do not edit, autogenerated
    (buildpath/"test/mozilla/data").install resource("mozilla-tests")
    (buildpath/"buildtools").install resource("buildtools")
    (buildpath/"third_party/WebKit/Source/platform/inspector_protocol").install resource("inspector_protocol")
    (buildpath/"test/simdjs/data").install resource("ecmascript_simd")
    (buildpath/"tools/mb").install resource("mb")
    (buildpath/"testing/gmock").install resource("googlemock")
    (buildpath/"tools/clang").install resource("clang")
    (buildpath/"third_party/markupsafe").install resource("markupsafe")
    (buildpath/"testing/gtest").install resource("googletest")
    (buildpath/"third_party/jinja2").install resource("jinja2")
    (buildpath/"build").install resource("build")
    (buildpath/"test/benchmarks/data").install resource("benchmarks")
    (buildpath/"tools/gyp").install resource("gyp")
    (buildpath/"test/test262/data").install resource("test262")
    (buildpath/"third_party/instrumented_libraries").install resource("instrumented_libraries")
    (buildpath/"tools/swarming_client").install resource("swarming")
    (buildpath/"test/test262/harness").install resource("test262-harness-py")
    (buildpath/"third_party/icu").install resource("icu")
    (buildpath/"base/trace_event/common").install resource("common")

    system "make", "native", "library=shared", "snapshot=on",
                   "console=readline", i18nsupport,
                   "strictaliasing=off"

    include.install Dir["include/*"]

    cd "out/native" do
      rm ["libgmock.a", "libgtest.a"]
      lib.install Dir["lib*"]
      bin.install "d8", "mksnapshot", "process", "v8_shell" => "v8"
    end
  end

  test do
    assert_equal "Hello World!", pipe_output("#{bin}/v8 -e 'print(\"Hello World!\")'").chomp
  end
end
