class Emscripten < Formula
  desc "LLVM bytecode to JavaScript compiler"
  homepage "https://kripken.github.io/emscripten-site/"

  # Get revision from https://github.com/emscripten-core/emsdk/blob/master/emscripten-releases-tags.txt
  # Open following link (replace bc367c257409d676e71c5511383228b7aabf1689 with revison got previously)
  # https://chromium.googlesource.com/emscripten-releases/+/bc367c257409d676e71c5511383228b7aabf1689/DEPS

  binaryen_revision = "fc6d2df4eedfef53a0a29fed1ff3ce4707556700"
  fastcomp_revision = "6c7e775325067e33fa60611e619a8b987b6d0c35"
  fastcomp_clang_revision = "98df4be387dde3e3918fa5bbb5fc43e1a0e1daac"
  llvm_project_revision = "12e915b3fcc55b8394dce3105a24c009e516d153"
  v8_revision = "4c8ffcbe3959f4a1b799bb9d6b7ef9b49bf6d144"
  wabt_revision = "04fd00d2fc29b565da350739d3a1f9c85267d5d2"
  waterfall_revision = "d43b36904743b7494a49ed47230d1506a749bfe1"

  stable do
    url "https://github.com/emscripten-core/emscripten/archive/1.38.47.tar.gz"
    sha256 "3412740c703432274f35a08e00cafa500a2f2effcc455484faee9e786b917b12"

    resource "binaryen" do
      url "https://github.com/WebAssembly/binaryen.git", :revision => binaryen_revision
    end

    resource "fastcomp" do
      url "https://github.com/emscripten-core/emscripten-fastcomp.git", :revision => fastcomp_revision
    end

    resource "fastcomp_clang" do
      url "https://github.com/emscripten-core/emscripten-fastcomp-clang.git", :revision => fastcomp_clang_revision
    end

    resource "llvm" do
      url "https://github.com/llvm/llvm-project.git", :revision => llvm_project_revision
    end

    resource "v8" do
      url "https://chromium.googlesource.com/v8/v8.git", :revision => v8_revision
    end

    resource "wabt" do
      url "https://github.com/WebAssembly/wabt.git", :revision => wabt_revision
    end

    resource "waterfall" do
      url "https://github.com/WebAssembly/waterfall.git", :revision => waterfall_revision
    end
  end

  bottle do
    cellar :any
    sha256 "4f8be86a67d0f1fc87c01c92dd0fe8112f1cd6c5b1ae210ac0528ce02ad36b8a" => :mojave
    sha256 "3abedeaff354db116142227d55d93232210b073549ab26c33b7f8c97fe8e897b" => :high_sierra
    sha256 "36d6ea5dd8eaff5b9f8adf9388bfc9bcab2d22b8b738a164378601e174cc9bca" => :sierra
  end

  head do
    url "https://github.com/emscripten-core/emscripten.git", :branch => "incoming"

    resource "fastcomp" do
      url "https://github.com/emscripten-core/emscripten-fastcomp.git", :branch => "incoming"
    end

    resource "fastcomp-clang" do
      url "https://github.com/emscripten-core/emscripten-fastcomp-clang.git", :branch => "incoming"
    end
  end

  depends_on "cmake" => :build
  depends_on "node"
  depends_on "python"
  depends_on "yuicompressor"

  def install
    ENV.cxx11

    # All files from the repository are required as emscripten is a collection
    # of scripts which need to be installed in the same layout as in the Git
    # repository.
    libexec.install Dir["*"]

    (buildpath/"fastcomp").install resource("fastcomp")
    (buildpath/"fastcomp/tools/clang").install resource("fastcomp-clang")

    cmake_args = std_cmake_args.reject { |s| s["CMAKE_INSTALL_PREFIX"] }
    cmake_args = [
      "-DCMAKE_BUILD_TYPE=Release",
      "-DCMAKE_INSTALL_PREFIX=#{libexec}/llvm",
      "-DLLVM_TARGETS_TO_BUILD='X86;JSBackend'",
      "-DLLVM_INCLUDE_EXAMPLES=OFF",
      "-DLLVM_INCLUDE_TESTS=OFF",
      "-DCLANG_INCLUDE_TESTS=OFF",
      "-DOCAMLFIND=/usr/bin/false",
      "-DGO_EXECUTABLE=/usr/bin/false",
    ]

    mkdir "fastcomp/build" do
      system "cmake", "..", *cmake_args
      system "make"
      system "make", "install"
    end

    %w[em++ em-config emar emcc emcmake emconfigure emlink.py emmake
       emranlib emrun emscons].each do |emscript|
      bin.install_symlink libexec/emscript
    end
  end

  def caveats; <<~EOS
    Manually set LLVM_ROOT to
      #{opt_libexec}/llvm/bin
    and comment out BINARYEN_ROOT
    in ~/.emscripten after running `emcc` for the first time.
  EOS
  end

  test do
    system bin/"emcc"
    assert_predicate testpath/".emscripten", :exist?, "Failed to create sample config"
  end
end
