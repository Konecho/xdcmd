from __future__ import annotations

from prompt_toolkit.application.current import get_app
from prompt_toolkit.layout import ScrollablePane
from prompt_toolkit.layout.screen import WritePosition


def clamp_scroll(scroll: int, content_height: int, window_height: int) -> int:
    return max(0, min(scroll, max(0, content_height - window_height)))


def reveal_scroll_delta(
    pane_top: int,
    pane_height: int,
    window_top: int,
    window_height: int,
) -> int:
    """Return how many lines the pane should scroll to reveal *window*.

    The coordinates are the ones from the last rendered screen, so they are
    relative to the terminal, not to the scrollable content.
    """
    pane_bottom = pane_top + pane_height

    if window_height <= pane_height:
        if window_top < pane_top:
            return window_top - pane_top
        if window_top + window_height > pane_bottom:
            return window_top + window_height - pane_bottom
    elif window_top < pane_top or window_top >= pane_bottom:
        # A window that is taller than the viewport cannot be shown at once.
        # Align its top with the top of the pane instead.
        return window_top - pane_top

    return 0


class ContentScrollablePane(ScrollablePane):
    """A ScrollablePane that keeps its scroll position while the content is
    focused.

    prompt_toolkit's default behaviour is to scroll the focused window into
    view on every render. That makes it impossible to read the rest of a reply
    that is taller than the terminal, because focus stays on the reply header.
    Here we disable that automatic behaviour and provide explicit scrolling.
    """

    def __init__(self, *args, **kwargs):
        kwargs.setdefault("keep_focused_window_visible", False)
        kwargs.setdefault("keep_cursor_visible", False)
        super().__init__(*args, **kwargs)
        self.last_write_position: WritePosition | None = None
        self.content_height = 0

    def write_to_screen(
        self,
        screen,
        mouse_handlers,
        write_position,
        parent_style,
        erase_bg,
        z_index,
    ) -> None:
        self.last_write_position = write_position

        # ScrollablePane computes this internally; keep the value so that
        # scrolling can be clamped before the next render.
        show_scrollbar = self.show_scrollbar()
        virtual_width = (
            write_position.width - 1 if show_scrollbar else write_position.width
        )
        virtual_height = self.content.preferred_height(
            virtual_width, self.max_available_height
        ).preferred
        self.content_height = min(
            max(virtual_height, write_position.height),
            self.max_available_height,
        )

        super().write_to_screen(
            screen,
            mouse_handlers,
            write_position,
            parent_style,
            erase_bg,
            z_index,
        )

    @property
    def page_size(self) -> int:
        if self.last_write_position is None:
            return 1
        return max(1, self.last_write_position.height - 2)

    def scroll_lines(self, lines: int) -> int:
        old_scroll = self.vertical_scroll
        self.vertical_scroll = clamp_scroll(
            self.vertical_scroll + lines,
            self.content_height,
            self.last_write_position.height if self.last_write_position else 0,
        )
        return self.vertical_scroll - old_scroll

    def scroll_half_page(self, direction: int) -> int:
        return self.scroll_lines(direction * max(1, self.page_size // 2))

    def _last_screen(self):
        return getattr(get_app().renderer, "_last_screen", None)

    def _window_position(self, window) -> WritePosition | None:
        if self.last_write_position is None:
            return None
        screen = self._last_screen()
        if screen is None:
            return None
        position = screen.visible_windows_to_write_positions.get(window)
        if position is None:
            return None

        pane = self.last_write_position
        if not (pane.xpos <= position.xpos < pane.xpos + pane.width):
            return None
        return position

    def align_window_top(self, window, margin: int = 0) -> int:
        """Scroll so that *window* starts near the top of the viewport."""
        position = self._window_position(window)
        if position is None or self.last_write_position is None:
            return 0
        return self.scroll_lines(
            position.ypos - (self.last_write_position.ypos + margin)
        )

    def reveal_window(self, window) -> None:
        position = self._window_position(window)
        if position is None or self.last_write_position is None:
            return

        pane = self.last_write_position
        self.vertical_scroll += reveal_scroll_delta(
            pane.ypos,
            pane.height,
            position.ypos,
            position.height,
        )

    def visible_button(self, scroll_delta: int = 0):
        """Return the topmost button-like window in the viewport.

        ``scroll_delta`` is the scroll that was just applied but is not
        reflected in the last rendered screen yet.
        """
        if self.last_write_position is None:
            return None
        screen = self._last_screen()
        if screen is None:
            return None

        pane = self.last_write_position
        candidates = []
        for window, position in screen.visible_windows_to_write_positions.items():
            if not hasattr(window, "buttonType"):
                continue
            if not (pane.xpos <= position.xpos < pane.xpos + pane.width):
                continue
            y = position.ypos - scroll_delta
            if pane.ypos <= y < pane.ypos + pane.height:
                candidates.append((y, id(window), window))

        return min(candidates)[2] if candidates else None
