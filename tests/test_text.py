from xdnmb.text import strip_invalid_xml_chars


def test_strip_invalid_xml_chars_removes_nul_and_controls():
    assert strip_invalid_xml_chars("a\x00b\x01c\x1fd") == "abcd"


def test_strip_invalid_xml_chars_keeps_whitespace():
    assert strip_invalid_xml_chars("a\nb\tc\rd") == "a\nb\tc\rd"


def test_strip_invalid_xml_chars_keeps_unicode():
    assert strip_invalid_xml_chars("测试🙂") == "测试🙂"
