class Cling < Formula
  desc "The cling C++ interpreter"
  homepage "https://root.cern.ch/cling"
  url "https://github.com/root-project/cling.git",
      :tag      => "v0.6",
      :revision => "82ac7bf1870abbedb7fe44f8e34a429538f26a8d"

  bottle do
    sha256 "361280b6e0673f196308e51b418955e2eab0df5289c278f5c196936909963363" => :mojave
    sha256 "2741d55c70dd4440a1a812ba4826688ee6d05dbb39dd083754ed72a37c997524" => :high_sierra
    sha256 "aafa124f8ef48c2839563f5485f2f747964d26a5a21b07d938e6a78e2db27eb4" => :sierra
  end

  depends_on "cmake" => :build

  resource "clang" do
    url "http://root.cern.ch/git/clang.git",
        :tag      => "cling-patches",
        :revision => "02c41d5edd15232b0b25ec1d842403552c2aceb4"
  end

  resource "llvm" do
    url "http://root.cern.ch/git/llvm.git",
        :tag      => "cling-patches",
        :revision => "e0b472e46eb5861570497c2b9efabf96f2d4a485"
  end

  def install
    (buildpath/"src").install resource("llvm")
    (buildpath/"src/tools/cling").install buildpath.children - [buildpath/"src"]
    (buildpath/"src/tools/clang").install resource("clang")
    mkdir "build" do
      system "cmake", *std_cmake_args, "../src",
                      "-DCMAKE_INSTALL_PREFIX=#{libexec}",
                      "-DCLING_CXX_PATH=clang++"
      system "make", "install"
    end
    bin.install_symlink libexec/"bin/cling"
    prefix.install_metafiles buildpath/"src/tools/cling"
  end

  test do
    test = <<~EOS
      '#include <stdio.h>' 'printf("Hello!")'
    EOS
    assert_equal "Hello!(int) 6", shell_output("#{bin}/cling #{test}").chomp
  end
end
