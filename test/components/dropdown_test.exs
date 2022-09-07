defmodule PrimerLive.Components.DropdownTest do
  use ExUnit.Case
  use PrimerLive
  import PrimerLive.Helpers.TestHelpers

  import Phoenix.LiveView.Helpers
  import Phoenix.LiveViewTest

  test "Called without options or inner_block: should render an error message" do
    assigns = []

    assert rendered_to_string(~H"""
           <.dropdown />
           """)
           |> format_html() ==
             """
             <div class="flash flash-error"><p>dropdown component received invalid options:</p><p>label: can&#39;t be blank</p><p>menu: can&#39;t be blank</p></div>
             """
             |> format_html()
  end

  test "Called without options: should render an error message" do
    assigns = []

    assert rendered_to_string(~H"""
           <.dropdown>Content</.dropdown>
           """)
           |> format_html() ==
             """
             <div class="flash flash-error"><p>dropdown component received invalid options:</p><p>label: can&#39;t be blank</p><p>menu: can&#39;t be blank</p></div>
             """
             |> format_html()
  end

  test "Called with slots label and menu: should render the dropdown element" do
    assigns = []

    assert rendered_to_string(~H"""
           <.dropdown>
             <:label>Label</:label>
             <:menu>Content</:menu>
           </.dropdown>
           """)
           |> format_html() ==
             """
             <details class="dropdown details-reset details-overlay d-inline-block">
             <summary class="btn" aria-haspopup="true">Label<div class="dropdown-caret"></div>
             </summary>
             <ul class="dropdown-menu dropdown-menu-se">Content</ul>
             </details>
             """
             |> format_html()
  end

  test "Slot: header" do
    assigns = []

    assert rendered_to_string(~H"""
           <.dropdown>
             <:menu>Content</:menu>
             <:header>Header</:header>
             <:label>Label</:label>
           </.dropdown>
           """)
           |> format_html() ==
             """
             <details class="dropdown details-reset details-overlay d-inline-block">
             <summary class="btn" aria-haspopup="true">Label<div class="dropdown-caret"></div>
             </summary>
             <div class="dropdown-menu dropdown-menu-se">
             <div class="dropdown-header">Header</div>
             <ul>
             Content</ul>
             </div>
             </details>
             """
             |> format_html()
  end

  test "Option: position" do
    assigns = []

    assert rendered_to_string(~H"""
           <.dropdown position="se">
             <:label>Label</:label>
             <:menu>Content</:menu>
           </.dropdown>
           <.dropdown position="ne">
             <:label>Label</:label>
             <:menu>Content</:menu>
           </.dropdown>
           <.dropdown position="e">
             <:label>Label</:label>
             <:menu>Content</:menu>
           </.dropdown>
           <.dropdown position="sw">
             <:label>Label</:label>
             <:menu>Content</:menu>
           </.dropdown>
           <.dropdown position="s">
             <:label>Label</:label>
             <:menu>Content</:menu>
           </.dropdown>
           <.dropdown position="w">
             <:label>Label</:label>
             <:menu>Content</:menu>
           </.dropdown>
           """)
           |> format_html() ==
             """
             <details class="dropdown details-reset details-overlay d-inline-block">
             <summary class="btn" aria-haspopup="true">Label<div class="dropdown-caret"></div>
             </summary>
             <ul class="dropdown-menu dropdown-menu-se">Content</ul>
             </details>
             <details class="dropdown details-reset details-overlay d-inline-block">
             <summary class="btn" aria-haspopup="true">Label<div class="dropdown-caret"></div>
             </summary>
             <ul class="dropdown-menu dropdown-menu-ne">Content</ul>
             </details>
             <details class="dropdown details-reset details-overlay d-inline-block">
             <summary class="btn" aria-haspopup="true">Label<div class="dropdown-caret"></div>
             </summary>
             <ul class="dropdown-menu dropdown-menu-e">Content</ul>
             </details>
             <details class="dropdown details-reset details-overlay d-inline-block">
             <summary class="btn" aria-haspopup="true">Label<div class="dropdown-caret"></div>
             </summary>
             <ul class="dropdown-menu dropdown-menu-sw">Content</ul>
             </details>
             <details class="dropdown details-reset details-overlay d-inline-block">
             <summary class="btn" aria-haspopup="true">Label<div class="dropdown-caret"></div>
             </summary>
             <ul class="dropdown-menu dropdown-menu-s">Content</ul>
             </details>
             <details class="dropdown details-reset details-overlay d-inline-block">
             <summary class="btn" aria-haspopup="true">Label<div class="dropdown-caret"></div>
             </summary>
             <ul class="dropdown-menu dropdown-menu-w">Content</ul>
             </details>
             """
             |> format_html()
  end

  test "Option: position (invalid)" do
    assigns = []

    assert rendered_to_string(~H"""
           <.dropdown position="x">
             <:label>Label</:label>
             <:menu>Content</:menu>
           </.dropdown>
           """)
           |> format_html() ==
             """
             <div class="flash flash-error"><p>dropdown component received invalid options:</p><p>position: is invalid</p></div>
             """
             |> format_html()
  end

  test "Option: class" do
    assigns = []

    assert rendered_to_string(~H"""
           <.dropdown class="x">
             <:label>Label</:label>
             <:menu>Content</:menu>
             Content
           </.dropdown>
           """)
           |> format_html() ==
             """
             <details class="dropdown details-reset details-overlay d-inline-block x">
             <summary class="btn" aria-haspopup="true">Label<div class="dropdown-caret"></div>
             </summary>
             <ul class="dropdown-menu dropdown-menu-se">Content</ul>
             </details>
             """
             |> format_html()
  end

  test "Option: classes" do
    assigns = []

    assert rendered_to_string(~H"""
           <.dropdown classes={
             %{
               dropdown: "dropdown-x",
               toggle: "toggle-x",
               caret: "caret-x",
               menu: "menu-x",
               header: "header-x"
             }
           }>
             <:label>Label</:label>
             <:header>Header</:header>
             <:menu>Content</:menu>
           </.dropdown>
           """)
           |> format_html() ==
             """
             <details class="dropdown details-reset details-overlay d-inline-block dropdown-x">
             <summary class="toggle-x" aria-haspopup="true">Label<div class="dropdown-caret caret-x"></div>
             </summary>
             <div class="dropdown-menu dropdown-menu-se menu-x">
             <div class="dropdown-header header-x">
             Header</div>
             <ul>
             Content</ul>
             </div>
             </details>
             """
             |> format_html()
  end

  test "Extra attributes" do
    assigns = []

    assert rendered_to_string(~H"""
           <.dropdown dir="rtl">
             <:label>Label</:label>
             <:menu>Content</:menu>
           </.dropdown>
           """)
           |> format_html() ==
             """
             <details class="dropdown details-reset details-overlay d-inline-block" dir="rtl">
             <summary class="btn" aria-haspopup="true">Label<div class="dropdown-caret"></div>
             </summary>
             <ul class="dropdown-menu dropdown-menu-se">Content</ul>
             </details>
             """
             |> format_html()
  end

  test "Full menu" do
    assigns = []

    assert rendered_to_string(~H"""
           <.dropdown
             open
             class="dropdown-x"
             classes={
               %{
                 toggle: "btn toggle-x"
               }
             }
           >
             <:label>
               <.octicon name="alert-16" />
             </:label>
             <:header>Header</:header>
             <:menu>
               <.dropdown_item href="#url">Dropdown item 1</.dropdown_item>
               <.dropdown_item href="#url">Dropdown item 2</.dropdown_item>
               <.dropdown_item is_divider />
               <.dropdown_item href="#url">Dropdown item 3</.dropdown_item>
             </:menu>
           </.dropdown>
           """)
           |> format_html() ==
             """
             <details class="dropdown details-reset details-overlay d-inline-block dropdown-x" open>
             <summary class="btn toggle-x" aria-haspopup="true"><svg class="octicon" xmlns="http://www.w3.org/2000/svg" width="16"
             height="16" viewBox="0 0 16 16">
             <path fill-rule="evenodd"
             d="M8.22 1.754a.25.25 0 00-.44 0L1.698 13.132a.25.25 0 00.22.368h12.164a.25.25 0 00.22-.368L8.22 1.754zm-1.763-.707c.659-1.234 2.427-1.234 3.086 0l6.082 11.378A1.75 1.75 0 0114.082 15H1.918a1.75 1.75 0 01-1.543-2.575L6.457 1.047zM9 11a1 1 0 11-2 0 1 1 0 012 0zm-.25-5.25a.75.75 0 00-1.5 0v2.5a.75.75 0 001.5 0v-2.5z">
             </path>
             </svg>
             <div class="dropdown-caret"></div>
             </summary>
             <div class="dropdown-menu dropdown-menu-se">
             <div class="dropdown-header">Header</div>
             <ul>
             <li href="#url" class="dropdown-item">Dropdown item 1</li>
             <li href="#url" class="dropdown-item">Dropdown item 2</li>
             <li class="dropdown-divider" role="separator"></li>
             <li href="#url" class="dropdown-item">Dropdown item 3</li>
             </ul>
             </div>
             </details>
             """
             |> format_html()
  end
end
