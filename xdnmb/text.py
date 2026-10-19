import re

# XML 1.0 does not allow most C0 control characters. prompt_toolkit's HTML
# parser uses minidom, which raises on them.
_INVALID_XML_CHARS = re.compile(r"[\x00-\x08\x0b\x0c\x0e-\x1f]")


def strip_invalid_xml_chars(text: str) -> str:
    return _INVALID_XML_CHARS.sub("", text)
