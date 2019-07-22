class QalculateGtk < Formula
  desc "Multi-purpose desktop calculator"
  homepage "https://qalculate.github.io/"
  url "https://github.com/Qalculate/qalculate-gtk/releases/download/v3.3.0/qalculate-gtk-3.3.0.tar.gz"
  sha256 "45b2ef84dc3c1cc77fff9b78b9a81d7b6e29f7ac6d2c4ed8cdde37a58de77da7"

  bottle do
    cellar :any
    sha256 "3104ddb1b29fc2d9c39e43e559362ef1b8fdb77973690c53410bd16659114709" => :mojave
    sha256 "64361989afde43f6117ab4f0bed220fb367c7cc5258af6217face7c35c52c60b" => :high_sierra
    sha256 "f64686ea0ecc8a266905ed73def45e1b533f0bb53919e744e2740b6a4477c940" => :sierra
  end

  depends_on "intltool" => :build
  depends_on "pkg-config" => :build
  depends_on "adwaita-icon-theme"
  depends_on "gtk+3"
  depends_on "libqalculate"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/qalculate-gtk", "-v"
  end
end
