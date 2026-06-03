defmodule ClaperWeb.EventLive.PostComponent do
  use ClaperWeb, :live_component

  alias Claper.Posts.Post

  def render(assigns) do
    ~H"""
    <div id={@id}>
      <%= if @post.attendee_identifier == @attendee_identifier || (not is_nil(@current_user) && @post.user_id == @current_user.id) do %>
        <div class="px-4 pt-3 pb-8 rounded-b-lg rounded-tl-lg bg-gray-700 text-white relative z-0 break-word">
          <button
            phx-click={
              JS.toggle(
                to: "#post-menu-#{@post.id}",
                out: "animate__animated animate__fadeOut",
                in: "animate__animated animate__fadeIn"
              )
            }
            phx-click-away={
              JS.hide(to: "#post-menu-#{@post.id}", transition: "animate__animated animate__fadeOut")
            }
            class="float-right mr-1"
          >
            <img src="/images/icons/ellipsis-horizontal-white.svg" class="h-5" />
          </button>

          <%= if @post.name || leader?(@post, @event, @leaders) || pinned?(@post) || answered?(@post) do %>
            <div class="inline-flex items-center">
              <%= if @post.name do %>
                <p class="text-white text-xs font-semibold mb-2 mr-2">{@post.name}</p>
              <% end %>
              <%= if leader?(@post, @event, @leaders) do %>
                <div class="inline-flex items-center space-x-1 justify-center px-3 py-0.5 rounded-full text-xs font-medium bg-supporting-yellow-100 text-supporting-yellow-800 mb-2">
                  <img src="/images/icons/star.svg" class="h-3" />
                  <span>{gettext("Host")}</span>
                </div>
              <% end %>

              <%= if pinned?(@post) do %>
                <div class="inline-flex items-center space-x-1 justify-center px-3 py-0.5 rounded-full text-xs font-medium bg-supporting-yellow-100 text-supporting-yellow-800 mb-2 ml-1">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    class="icon icon-tabler icon-tabler-pin-filled"
                    width="12"
                    height="12"
                    viewBox="0 0 24 24"
                    stroke-width="2"
                    stroke="currentColor"
                    fill="none"
                    stroke-linecap="round"
                    stroke-linejoin="round"
                  >
                    <path stroke="none" d="M0 0h24v24H0z" fill="none"></path>
                    <path
                      d="M15.113 3.21l.094 .083l5.5 5.5a1 1 0 0 1 -1.175 1.59l-3.172 3.171l-1.424 3.797a1 1 0 0 1 -.158 .277l-.07 .08l-1.5 1.5a1 1 0 0 1 -1.32 .082l-.095 -.083l-2.793 -2.792l-3.793 3.792a1 1 0 0 1 -1.497 -1.32l.083 -.094l3.792 -3.793l-2.792 -2.793a1 1 0 0 1 -.083 -1.32l.083 -.094l1.5 -1.5a1 1 0 0 1 .258 -.187l.098 -.042l3.796 -1.425l3.171 -3.17a1 1 0 0 1 1.497 -1.26z"
                      stroke-width="0"
                      fill="currentColor"
                    >
                    </path>
                  </svg>
                  <span>{gettext("Pinned")}</span>
                </div>
              <% end %>

              <.answered_badge :if={answered?(@post)} />
            </div>
          <% end %>

          <div
            id={"post-menu-#{@post.id}"}
            class="hidden absolute right-4 top-7 bg-white rounded-lg px-5 py-2 animate__faster"
          >
            <span class="text-red-500">
              {link(gettext("Delete"),
                to: "#",
                phx_click: "delete",
                phx_value_id: @post.uuid,
                phx_value_event_id: @event.uuid,
                data: [confirm: gettext("Are you sure?")]
              )}
            </span>
          </div>
          <p>{ClaperWeb.Helpers.format_body(@post.body)}</p>

          <div class="flex h-6 text-sm float-right text-white space-x-2">
            <%= for %{emoji: emoji} <- @event.reactions || [] do %>
              <% count = Post.reaction_count(@post, emoji) %>
              <%= if count > 0 do %>
                <div class="flex px-1 items-center">
                  <span class="text-base leading-none">{emoji}</span>
                  <span class="ml-1 text-white">{count}</span>
                </div>
              <% end %>
            <% end %>
          </div>
        </div>
      <% else %>
        <div class="px-4 pt-3 pb-8 rounded-b-lg rounded-tr-lg bg-white text-black relative z-0 break-all">
          <%= if @post.name || leader?(@post, @event, @leaders) do %>
            <div class="inline-flex items-center">
              <%= if @post.name do %>
                <p class="text-black text-xs font-semibold mb-2 mr-2">{@post.name}</p>
              <% end %>
              <%= if leader?(@post, @event, @leaders) do %>
                <div class="inline-flex items-center space-x-1 justify-center px-3 py-0.5 rounded-full text-xs font-medium bg-supporting-yellow-100 text-supporting-yellow-800 mb-2">
                  <img src="/images/icons/star.svg" class="h-3" />
                  <span>{gettext("Host")}</span>
                </div>
              <% end %>
            </div>
          <% end %>

          <%= if @is_leader do %>
            <button
              phx-click={
                JS.toggle(
                  to: "#post-menu-#{@post.id}",
                  out: "animate__animated animate__fadeOut",
                  in: "animate__animated animate__fadeIn"
                )
              }
              phx-click-away={
                JS.hide(
                  to: "#post-menu-#{@post.id}",
                  transition: "animate__animated animate__fadeOut"
                )
              }
              class="float-right mr-1"
            >
              <img src="/images/icons/ellipsis-horizontal.svg" class="h-5" />
            </button>
            <div
              id={"post-menu-#{@post.id}"}
              class="hidden absolute right-4 top-7 bg-gray-900 rounded-lg px-5 py-2"
            >
              <span class="text-red-500">
                {link(gettext("Delete"),
                  to: "#",
                  phx_click: "delete",
                  phx_value_id: @post.uuid,
                  phx_value_event_id: @event.uuid
                )}
              </span>
            </div>
          <% end %>

          <%= if pinned?(@post) do %>
            <div class="inline-flex items-center space-x-1 justify-center px-3 py-0.5 rounded-full text-xs font-medium bg-supporting-yellow-100 text-supporting-yellow-800 mb-2 ml-1">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="icon icon-tabler icon-tabler-pin-filled"
                width="12"
                height="12"
                viewBox="0 0 24 24"
                stroke-width="2"
                stroke="currentColor"
                fill="none"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path stroke="none" d="M0 0h24v24H0z" fill="none"></path>
                <path
                  d="M15.113 3.21l.094 .083l5.5 5.5a1 1 0 0 1 -1.175 1.59l-3.172 3.171l-1.424 3.797a1 1 0 0 1 -.158 .277l-.07 .08l-1.5 1.5a1 1 0 0 1 -1.32 .082l-.095 -.083l-2.793 -2.792l-3.793 3.792a1 1 0 0 1 -1.497 -1.32l.083 -.094l3.792 -3.793l-2.792 -2.793a1 1 0 0 1 -.083 -1.32l.083 -.094l1.5 -1.5a1 1 0 0 1 .258 -.187l.098 -.042l3.796 -1.425l3.171 -3.17a1 1 0 0 1 1.497 -1.26z"
                  stroke-width="0"
                  fill="currentColor"
                >
                </path>
              </svg>
              <span>{gettext("Pinned")}</span>
            </div>
          <% end %>

          <.answered_badge :if={answered?(@post)} />

          <p>{ClaperWeb.Helpers.format_body(@post.body)}</p>

          <div class="flex h-6 text-xs float-right space-x-2">
            <%= if @reaction_enabled do %>
              <%= for %{emoji: emoji} <- @event.reactions || [] do %>
                <% count = Post.reaction_count(@post, emoji) %>
                <% reacted = Enum.member?(Map.get(@reacted_posts, emoji, []), @post.id) %>
                <button
                  phx-click={if reacted, do: "unreact", else: "react"}
                  phx-value-type={emoji}
                  phx-value-post-id={@post.uuid}
                  class={"flex rounded-full px-3 py-1 border border-gray-300 items-center #{if reacted, do: "bg-gray-100", else: "bg-white"}"}
                >
                  <span class="text-base leading-none">{emoji}</span>
                  <%= if count > 0 do %>
                    <span class="ml-1">{count}</span>
                  <% end %>
                </button>
              <% end %>
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  defp leader?(post, event, leaders) do
    !is_nil(post.user_id) &&
      (post.user_id == event.user_id ||
         Enum.any?(leaders, fn leader ->
           leader.user_id == post.user_id
         end))
  end

  defp pinned?(post), do: post.pinned

  defp answered?(%{answered: true}), do: true
  defp answered?(_post), do: false

  defp answered_badge(assigns) do
    ~H"""
    <div class="inline-flex items-center space-x-1 justify-center px-3 py-0.5 rounded-full text-xs font-medium bg-green-500 text-white mb-2 ml-1">
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 20 20"
        fill="currentColor"
        class="w-3.5 h-3.5"
      >
        <path
          fill-rule="evenodd"
          d="M16.704 4.153a.75.75 0 0 1 .143 1.052l-8 10.5a.75.75 0 0 1-1.127.075l-4.5-4.5a.75.75 0 0 1 1.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 0 1 1.05-.143Z"
          clip-rule="evenodd"
        />
      </svg>
      <span>{gettext("Answered")}</span>
    </div>
    """
  end
end
