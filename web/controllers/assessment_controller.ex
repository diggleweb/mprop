defmodule Properties.AssessmentController do
  use Properties.Web, :controller
  alias Properties.Assessment
  plug Properties.Plugs.Location

  def show(conn, %{"id" => id}) do
    id = String.to_integer(id)
    assessment = Repo.get!(Assessment, id)
    render(conn, "show.json", assessment: assessment)
  end

  def index(conn, params) do
    location = conn.assigns[:location]
    point = %Geo.Point{coordinates: {location.longitude, location.latitude}, srid: 4326}

    min_bathrooms = String.to_integer(params["minBathrooms"] || "0")
    max_bathrooms = String.to_integer(params["maxBathrooms"] || "0")
    min_bedrooms = String.to_integer(params["minBedrooms"] || "0")
    max_bedrooms = String.to_integer(params["maxBedrooms"] || "0")
    zipcode = params["zipcode"]
    land_use = params["land_use"]
    parking_type = params["parking_type"]
    number_units = params["number_units"]
    year = params["year"] || 2016
    assessments = from(p in Assessment,
                   where: p.year == ^year,
                   order_by: [desc: p.last_assessment_amount])
                 |> Assessment.within(point, location.radius_in_m)
                 |> Assessment.filter_by_bathrooms(min_bathrooms, max_bathrooms)
                 |> Assessment.filter_by_bedrooms(min_bedrooms, max_bedrooms)
                 |> Assessment.filter_by_zipcode(zipcode)
                 |> Assessment.maybe_filter_by(:land_use, land_use)
                 |> Assessment.maybe_filter_by(:parking_type, parking_type)
                 |> Assessment.maybe_filter_by(:number_units, number_units)
                 |> Repo.all
    render conn, "index.json", assessments: assessments
  end
end