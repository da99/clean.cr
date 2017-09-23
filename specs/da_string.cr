

def assert(a , b, c)
  case b
  when :==
    return true if a == c
    raise Exception.new("#{a.inspect} != #{c.inspect}")
  else
    raise Exception.new("Unknown comparison: #{b.inspect}")
  end
end # === def assert

describe ":clean_utf8" do

  it "returns nil if nb (non-breaking) spaces (160 codepoint)" do
    str = [160, 160,64, 116, 119, 101, 108, 108, 121, 109, 101, 160, 102, 105, 108, 109].map { |x|
      x.chr
    }.join
    # "**@twellyme*film"

    assert nil, :==, Mu_Clean.string(str)
  end

  utf8_whitespace = "\u205f \u3000 \u0085 \u00a0 \u2007"
  it "replaces utf-8 whitespace with a space: #{utf8_whitespace}" do
    str = utf8_whitespace
    new_str = Mu_Clean.string(str) || "error"
    assert "", :==, new_str.split.uniq.join
  end

  it "replaces the No-Break Space (U+00A0) with an empty space" do
    str = "a\u{A0}\u00A0A"
    assert "a  A", :==, Mu_Clean.string(str)
  end

  it "replaces \\r with space" do
    str = "r\r\rR"
    assert "r  R", :==, Mu_Clean.string(str)
  end

  it "replaces each tab with 2 spaces" do
    s = ".\t \tTAB"
    assert ".     TAB", :==, Mu_Clean.string(s)
  end

end # === describe :clean_utf8 ===








