defmodule ClaperWeb.EventLive.ManageablePostComponent do
  use ClaperWeb, :live_component

  def render(assigns) do
    assigns = assigns |> assign_new(:readonly, fn -> false end)

    ~H"""
    <div
      id={"#{@id}"}
      class={"#{if ClaperWeb.Helpers.body_without_links(@post.body) =~ "?", do: "border-supporting-yellow-400 border-2"} flex flex-col md:block px-4 pb-2 pt-3 rounded-b-lg rounded-tr-lg bg-white relative shadow-md text-black break-all mt-2"}
    >
      <div
        :if={ClaperWeb.Helpers.body_without_links(@post.body) =~ "?"}
        class="inline-flex items-center space-x-1 justify-center px-3 py-0.5 rounded-full text-xs font-medium bg-supporting-yellow-400 text-white mb-2"
      >
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 16 16"
          fill="currentColor"
          class="w-4 h-4"
        >
          <path
            fill-rule="evenodd"
            d="M15 8A7 7 0 1 1 1 8a7 7 0 0 1 14 0Zm-6 3.5a1 1 0 1 1-2 0 1 1 0 0 1 2 0ZM7.293 5.293a1 1 0 1 1 .99 1.667c-.459.134-1.033.566-1.033 1.29v.25a.75.75 0 1 0 1.5 0v-.115a2.5 2.5 0 1 0-2.518-4.153.75.75 0 1 0 1.061 1.06Z"
            clip-rule="evenodd"
          />
        </svg>

        <span>{gettext("Question")}</span>
      </div>
      <div :if={!@readonly} class="float-right mr-1">
        <%= if @post.attendee_identifier do %>
          <span class="text-yellow-500">
            {link(
              if @post.pinned do
                gettext("Unpin")
              else
                gettext("Pin")
              end,
              to: "#",
              phx_click: "pin",
              phx_value_id: @post.uuid,
              phx_value_event_id: @event.uuid
            )}
          </span>
          /
          <span class="text-red-500">
            {link(gettext("Ban"),
              to: "#",
              phx_click: "ban",
              phx_value_attendee_identifier: @post.attendee_identifier,
              data: [
                confirm:
                  gettext(
                    "Blocking this user will delete all his messages and he will not be able to join again, confirm ?"
                  )
              ]
            )}
          </span>
          /
        <% else %>
          <span class="text-yellow-500">
            {link(
              if @post.pinned do
                gettext("Unpin")
              else
                gettext("Pin")
              end,
              to: "#",
              phx_click: "pin",
              phx_value_id: @post.uuid,
              phx_value_event_id: @event.uuid
            )}
          </span>
          /
          <span class="text-red-500">
            {link(gettext("Ban"),
              to: "#",
              phx_click: "ban",
              phx_value_user_id: @post.user_id,
              data: [
                confirm:
                  gettext(
                    "Blocking this user will delete all his messages and he will not be able to join again, confirm ?"
                  )
              ]
            )}
          </span>
          /
        <% end %>
        <span class="text-red-500">
          {link(gettext("Delete"),
            to: "#",
            phx_click: "delete",
            phx_value_id: @post.uuid,
            phx_value_event_id: @event.uuid
          )}
        </span>
      </div>

      <div class="flex space-x-3 items-center">
        <%= if @post.attendee_identifier do %>
          <img
            class="h-8 w-8"
            src={"https://api.dicebear.com/7.x/personas/svg?seed=#{@post.attendee_identifier}"}
          />
        <% else %>
          <img
            class="h-8 w-8"
            src={"https://api.dicebear.com/7.x/personas/svg?seed=#{@post.user_id}"}
          />
        <% end %>

        <div class="flex flex-col">
          <%= if @post.name do %>
            <p class="text-black text-sm font-semibold mr-2">
              {@post.name}
            </p>
          <% end %>

          <p class="text-xl">
            {ClaperWeb.Helpers.format_body(@post.body)}
          </p>
        </div>
      </div>

      <%= if has_reactions?(@post) do %>
        <div class="flex h-6 space-x-2 text-base text-gray-500 pb-3 items-center mt-5">
          <%= for {emoji, count} <- Enum.sort(@post.reaction_counts || %{}), count > 0 do %>
            <div class="flex items-center">
              <span class="text-base leading-none">{emoji}</span>
              <span class="ml-1">{count}</span>
            </div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp has_reactions?(%{reaction_counts: counts}) when is_map(counts) do
    Enum.any?(counts, fn {_emoji, count} -> count > 0 end)
  end

  defp has_reactions?(_post), do: false
end
