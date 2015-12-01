defmodule Rumbl.VideoChannel do
	use Rumbl.Web, :channel

	def join("videos:" <> video_id, _params, socket) do
		# :timer.send_interval(5_000, :ping)
		video = Repo.get!(Rumbl.Video, video_id)
		annotations = Repo.all(
			from a in assoc(video, :annotations),
			order_by: [desc: a.at],
			limit: 200,
			preload: [:user]
		)

		resp = %{annotations: Phoenix.View.render_many(annotations, AnnotationView, "annotation.json")}
		{:ok, assign(socket, :video_id, video_id)}
	end

	# def handle_info(:ping, socket) do
	# 	count = socket.assigns[:count] || 1
	# 	push socket, "ping", %{count: count}

	# 	{:noreply, assign(socket, :count, count + 1)}
	# end

	def handle_in("new_annotation", params, socket) do
		user = socket.assigns.current_user

		changeset = 
			user
			|> build(:annotations, video_id: socket.assigns.video_id)
			|> Rumbl.Annotation.changeset(params)

		case Repo.insert(changeset) do
			{:ok, annotation} ->
				broadcast! socket, "new_annotation", %{user: Rumbl.UserView.render("user.json", %{user: user}),
					body: annotation.body,
					at: annotation.at
				}
				{:reply, :ok, socket}

			{:error, changeset} ->
				{:reply, {:error, %{errors: changeset}}, socket}
		end
	end
end