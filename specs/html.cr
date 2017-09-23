

BRACKET = "
  < %3C &lt &lt; &LT &LT; &#60 &#060 &#0060
  &#00060 &#000060 &#0000060 &#60; &#060; &#0060; &#00060;
  &#000060; &#0000060; &#x3c &#x03c &#x003c &#x0003c &#x00003c
  &#x000003c &#x3c; &#x03c; &#x003c; &#x0003c; &#x00003c;
  &#x000003c; &#X3c &#X03c &#X003c &#X0003c &#X00003c &#X000003c
  &#X3c; &#X03c; &#X003c; &#X0003c; &#X00003c; &#X000003c;
  &#x3C &#x03C &#x003C &#x0003C &#x00003C &#x000003C &#x3C; &#x03C;
  &#x003C; &#x0003C; &#x00003C; &#x000003C; &#X3C &#X03C
  &#X003C &#X0003C &#X00003C &#X000003C &#X3C; &#X03C; &#X003C; &#X0003C;
  &#X00003C; &#X000003C; \x3c \x3C \u003c \u003C
"

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

describe ":unescape_html" do

  it "un-escapes until it can no longer escape." do
    str = "Hello < Hello <"
    assert str, :==, Mu_Clean.unescape_html(
      3.times.reduce(str) { |acc, i| HTML.escape(acc) }
    )
  end

  it "un-escapes escaped text mixed with HTML" do
    s = "<p>Hi&amp;</p>";
    assert "<p>Hi&</p>", :==, Mu_Clean.unescape_html(s);
  end

  hello_with_special_chars = "Hello & World ©®∆"
  it "un-escapes special chars: \"#{hello_with_special_chars}\"" do
    s = "Hello &amp; World &#169;&#174;&#8710;"
    assert hello_with_special_chars, :==, Mu_Clean.unescape_html(s)
  end

  it "un-escapes all 70 different combos of '<'" do
    assert "< %3C", :==, Mu_Clean.unescape_html(BRACKET).split.uniq.join(" ")
  end

end # === describe :un_e


describe ":escape_html" do

  escape_tag_chars = "& < > \" ' /"
  it "escapes the tag related chars: #{escape_tag_chars}" do
    target = "&amp; &lt; &gt; &quot; &#x27; &#x2F;"
    assert target , :==, Mu_Clean.escape_html(escape_tag_chars)
  end # === it "escapes the following characters: "

  it "does not re-escape already escaped text mixed with HTML" do
    html = "<p>Hi</p>";
    escaped = Mu_Clean.escape_html(html);
    assert Mu_Clean.escape_html(escaped + html), :==, Mu_Clean.escape_html(html + html)
  end

  it "escapes special chars: \"Hello ©®∆\"" do
    s = "Hello & World ©®∆"
    t = "Hello &amp; World &#169;&#174;&#8710;"
    t = "Hello &amp; World &copy;&reg;&#x2206;"
    assert t, :==, Mu_Clean.escape_html(s)
  end

  it "escapes all 70 different combos of '<'" do
    assert "&lt; %3C", :==, Mu_Clean.escape_html(BRACKET).split.uniq.join(" ")
  end

  it "escapes all keys in nested objects" do
    html = "<b>test</b>"
    t    = {" a &gt;" => {" a &gt;" => Mu_Clean.escape_html(html) }}
    assert t, :==, Mu_Clean.escape_html({" a >" => {" a >" => html}})
  end

  it "escapes all values in nested objects" do
    html = "<b>test</b>"
    t    = {name: {name: Mu_Clean.escape_html(html)}}
    assert t, :==, Mu_Clean.escape_html({name:{name: html}})
  end

  it "escapes all values in nested arrays" do
    html = "<b>test</b>"
    assert [{name: {name: Mu_Clean.escape_html(html)}}], :==, Mu_Clean.escape_html([{name:{name: html}}])
  end

  "uri url href".split.each { |k| # ==============================================

    it "escapes values of keys :#{k} that are valid /path" do
      a = {:key=>{:"#{k}" => "/path/mine/&"}}
      t = {:key=>{:"#{k}" => "/path/mine/&amp;"}}
      assert t, :==, Mu_Clean.escape_html(a)
    end

    it "sets nil any keys ending with :#{k} and have invalid uri" do
      a = {:key=>{"#{k}" => "javascript:alert(s)"}}
      t = {:key=>{"#{k}" => nil                  }}
      assert t, :==, Mu_Clean.escape_html(a)
    end

    it "sets nil any keys ending with _#{k} and have invalid uri" do
      a = {:key=>{"my_#{k}" => "javascript:alert(s)"}}
      t = {:key=>{"my_#{k}" => nil                  }}
      assert t, :==, Mu_Clean.escape_html(a)
    end

    it "escapes values of keys with _#{k} that are valid https uri" do
      a = {:key=>{"my_#{k}" => "https://www.yahoo.com/&"}}
      t = {:key=>{"my_#{k}" => "https://www.yahoo.com/&amp;"}}
      assert t, :==, Mu_Clean.escape_html(a)
    end

    it "escapes values of keys with _#{k} that are valid uri" do
      a = {:key=>{"my_#{k}" => "http://www.yahoo.com/&"}}
      t = {:key=>{"my_#{k}" => "http://www.yahoo.com/&amp;"}}
      assert t, :==, Mu_Clean.escape_html(a)
    end

    it "escapes values of keys ending with _#{k} that are valid /path" do
      a = {:key=>{"my_#{k}" => "/path/mine/&"}}
      t = {:key=>{"my_#{k}" => "/path/mine/&amp;"}}
      assert t, :==, Mu_Clean.escape_html(a)
    end

    it "allows unicode uris" do
      a = {:key=>{"my_#{k}" => "http://кц.рф"}}
      t = {:key=>{"my_#{k}" => "http://&#x43a;&#x446;.&#x440;&#x444;"}}
      assert t, :==, Mu_Clean.escape_html(a)
    end
  }

  [true, false].each do |v|
    it "does not escape #{v.inspect}" do
      a = {"something"=>v}
      assert a, :==, Mu_Clean.escape_html(a)
    end
  end

  it "does not escape numbers" do
    a = {"something"=>1.to_i64}
    assert a, :==, Mu_Clean.escape_html(a)
  end

end # === end desc






