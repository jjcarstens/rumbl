defmodule Rumbl.AnnotationView do
	use Rumbl.Web, :view

	def render("annotation.json", %{annotaiton: ann}) do
		%{
			id: ann.id,
			body: ann.body,
			at: ann.at,
			user: render_one(ann.user, Rumbl.UserView, "user.json")
		}
	end
end