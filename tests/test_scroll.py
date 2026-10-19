from prompt_toolkit.layout import Window
from prompt_toolkit.layout.screen import WritePosition

from xdnmb.scroll import (
    ContentScrollablePane,
    clamp_scroll,
    is_scrolled_out,
    reveal_scroll_delta,
)


def make_pane(height: int = 10, content_height: int = 100) -> ContentScrollablePane:
    pane = ContentScrollablePane(Window())
    pane.last_write_position = WritePosition(xpos=0, ypos=0, width=10, height=height)
    pane.content_height = content_height
    return pane


def test_clamp_scroll():
    assert clamp_scroll(-3, 100, 10) == 0
    assert clamp_scroll(5, 100, 10) == 5
    assert clamp_scroll(95, 100, 10) == 90
    assert clamp_scroll(5, 5, 10) == 0


def test_reveal_window_above_viewport():
    assert reveal_scroll_delta(10, 20, 5, 2) == -5


def test_reveal_window_below_viewport():
    assert reveal_scroll_delta(10, 20, 29, 2) == 1


def test_reveal_window_already_visible():
    assert reveal_scroll_delta(10, 20, 12, 4) == 0


def test_reveal_tall_window_aligns_top():
    assert reveal_scroll_delta(10, 10, 4, 30) == -6
    assert reveal_scroll_delta(10, 10, 25, 30) == 15


def test_content_scrollable_pane_scrolls_line_by_line():
    pane = make_pane()
    assert pane.scroll_lines(3) == 3
    assert pane.vertical_scroll == 3
    assert pane.scroll_lines(-5) == -3
    assert pane.vertical_scroll == 0


def test_content_scrollable_pane_stops_at_bottom():
    pane = make_pane(content_height=30)
    assert pane.scroll_lines(100) == 20
    assert pane.vertical_scroll == 20
    assert pane.scroll_lines(1) == 0


def test_content_scrollable_pane_page_size():
    pane = ContentScrollablePane(Window())
    assert pane.page_size == 1

    pane = make_pane(height=12)
    assert pane.page_size == 10


def test_content_scrollable_pane_does_not_follow_focus_or_cursor():
    pane = ContentScrollablePane(Window())
    assert not pane.keep_focused_window_visible()
    assert not pane.keep_cursor_visible()


def test_content_scrollable_pane_can_keep_cursor_visible():
    pane = ContentScrollablePane(Window(), keep_cursor_visible=True)
    assert pane.keep_cursor_visible()


def test_is_scrolled_out():
    # viewport: content lines 10..29
    assert is_scrolled_out(0, 5, 10, 20) is True
    assert is_scrolled_out(5, 10, 10, 20) is False
    assert is_scrolled_out(10, 5, 10, 20) is False
    assert is_scrolled_out(30, 5, 10, 20) is True
    assert is_scrolled_out(25, 3, 10, 20) is False
